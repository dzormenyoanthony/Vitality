import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';

import '../../features/blood_pressure/data/app_database.dart';
import '../utils/logger.dart';

/// A local row as seen by [_reconcileCollection], independent of which
/// Drift table it came from.
class _SyncRow {
  _SyncRow({
    required this.id,
    required this.remoteId,
    required this.deletedAt,
    required this.updatedAt,
    required this.fields,
  });

  final int id;
  final String? remoteId;
  final DateTime? deletedAt;
  final DateTime updatedAt;

  /// Firestore-ready field map (excludes `updatedAt`, which
  /// [_reconcileCollection] adds itself from [updatedAt]).
  final Map<String, dynamic> fields;
}

/// Reconciles local Drift readings/reminders with their Firestore mirror
/// (PROJECT_SPEC.md §21-22): pulls remote changes not yet reflected
/// locally, pushes local changes not yet reflected remotely, and
/// propagates pending soft-deletes. Conflicts (a row changed on both
/// sides) resolve by `updatedAt` — newer wins; adequate for a single-user
/// app with no real collaborative-edit scenario.
///
/// This is the "catch-up" half of sync — the other half is each
/// repository's own best-effort push-after-write
/// (`DriftBloodPressureRepository`/`DriftReminderRepository`), which
/// handles the common "online, save immediately" case. `syncAll` instead
/// covers: a fresh device/reinstall downloading existing history, and
/// catching up anything that failed to push while offline.
class SyncCoordinator {
  SyncCoordinator(this._db, this._firestore);

  final AppDatabase _db;
  final FirebaseFirestore _firestore;

  Future<void> syncAll(String uid) async {
    await _syncReadings(uid);
    await _syncReminders(uid);
  }

  Future<void> _syncReadings(String uid) async {
    try {
      final collection = _firestore.collection('users').doc(uid).collection('readings');
      await _reconcileCollection(
        collection: collection,
        fetchLocal: () async {
          final rows = await _db.select(_db.readings).get();
          return rows
              .map(
                (row) => _SyncRow(
                  id: row.id,
                  remoteId: row.remoteId,
                  deletedAt: row.deletedAt,
                  updatedAt: row.updatedAt,
                  fields: {
                    'systolic': row.systolic,
                    'diastolic': row.diastolic,
                    'pulse': row.pulse,
                    'timestamp': Timestamp.fromDate(row.timestamp),
                    'notes': row.notes,
                    'measurementContext': row.measurementContext,
                    'createdAt': Timestamp.fromDate(row.createdAt),
                  },
                ),
              )
              .toList();
        },
        insertLocal: (data, remoteId) => _db
            .into(_db.readings)
            .insert(
              ReadingsCompanion.insert(
                systolic: data['systolic'] as int,
                diastolic: data['diastolic'] as int,
                pulse: Value(data['pulse'] as int?),
                timestamp: (data['timestamp'] as Timestamp).toDate(),
                notes: Value(data['notes'] as String?),
                measurementContext: Value(data['measurementContext'] as String?),
                createdAt: (data['createdAt'] as Timestamp).toDate(),
                updatedAt: (data['updatedAt'] as Timestamp).toDate(),
                remoteId: Value(remoteId),
              ),
            ),
        updateLocal: (id, data) => (_db.update(_db.readings)..where((r) => r.id.equals(id))).write(
          ReadingsCompanion(
            systolic: Value(data['systolic'] as int),
            diastolic: Value(data['diastolic'] as int),
            pulse: Value(data['pulse'] as int?),
            timestamp: Value((data['timestamp'] as Timestamp).toDate()),
            notes: Value(data['notes'] as String?),
            measurementContext: Value(data['measurementContext'] as String?),
            updatedAt: Value((data['updatedAt'] as Timestamp).toDate()),
          ),
        ),
        setLocalRemoteId: (id, remoteId) => (_db.update(_db.readings)..where((r) => r.id.equals(id))).write(
          ReadingsCompanion(remoteId: Value(remoteId)),
        ),
        hardDeleteLocal: (id) => (_db.delete(_db.readings)..where((r) => r.id.equals(id))).go(),
      );
    } catch (error, stackTrace) {
      AppLogger.error('Failed to sync readings', error: error, stackTrace: stackTrace);
    }
  }

  Future<void> _syncReminders(String uid) async {
    try {
      final collection = _firestore.collection('users').doc(uid).collection('reminders');
      await _reconcileCollection(
        collection: collection,
        fetchLocal: () async {
          final rows = await _db.select(_db.reminders).get();
          return rows
              .map(
                (row) => _SyncRow(
                  id: row.id,
                  remoteId: row.remoteId,
                  deletedAt: row.deletedAt,
                  updatedAt: row.updatedAt,
                  fields: {
                    'label': row.label,
                    'hour': row.hour,
                    'minute': row.minute,
                    'daysOfWeek': row.daysOfWeek,
                    'enabled': row.enabled,
                    'createdAt': Timestamp.fromDate(row.createdAt),
                  },
                ),
              )
              .toList();
        },
        insertLocal: (data, remoteId) => _db
            .into(_db.reminders)
            .insert(
              RemindersCompanion.insert(
                label: data['label'] as String,
                hour: data['hour'] as int,
                minute: data['minute'] as int,
                daysOfWeek: data['daysOfWeek'] as String,
                enabled: Value(data['enabled'] as bool),
                createdAt: (data['createdAt'] as Timestamp).toDate(),
                updatedAt: (data['updatedAt'] as Timestamp).toDate(),
                remoteId: Value(remoteId),
              ),
            ),
        updateLocal: (id, data) => (_db.update(_db.reminders)..where((r) => r.id.equals(id))).write(
          RemindersCompanion(
            label: Value(data['label'] as String),
            hour: Value(data['hour'] as int),
            minute: Value(data['minute'] as int),
            daysOfWeek: Value(data['daysOfWeek'] as String),
            enabled: Value(data['enabled'] as bool),
            updatedAt: Value((data['updatedAt'] as Timestamp).toDate()),
          ),
        ),
        setLocalRemoteId: (id, remoteId) => (_db.update(_db.reminders)..where((r) => r.id.equals(id))).write(
          RemindersCompanion(remoteId: Value(remoteId)),
        ),
        hardDeleteLocal: (id) => (_db.delete(_db.reminders)..where((r) => r.id.equals(id))).go(),
      );
    } catch (error, stackTrace) {
      AppLogger.error('Failed to sync reminders', error: error, stackTrace: stackTrace);
    }
  }

  /// Table-agnostic pull/push/tombstone reconciliation against
  /// [collection], driven entirely through the supplied callbacks so the
  /// same logic serves both readings and reminders.
  Future<void> _reconcileCollection({
    required CollectionReference<Map<String, dynamic>> collection,
    required Future<List<_SyncRow>> Function() fetchLocal,
    required Future<void> Function(Map<String, dynamic> data, String remoteId) insertLocal,
    required Future<void> Function(int id, Map<String, dynamic> data) updateLocal,
    required Future<void> Function(int id, String remoteId) setLocalRemoteId,
    required Future<void> Function(int id) hardDeleteLocal,
  }) async {
    final remoteSnapshot = await collection.get();
    final remoteDocs = {for (final doc in remoteSnapshot.docs) doc.id: doc.data()};
    final localRows = await fetchLocal();
    final localByRemoteId = {
      for (final row in localRows)
        if (row.remoteId != null) row.remoteId!: row,
    };

    // Pull: a remote doc with no local counterpart, or one that's newer
    // than what's stored locally.
    for (final entry in remoteDocs.entries) {
      final remoteId = entry.key;
      final data = entry.value;
      final remoteUpdatedAt = (data['updatedAt'] as Timestamp).toDate();
      final localRow = localByRemoteId[remoteId];

      if (localRow == null) {
        await insertLocal(data, remoteId);
      } else if (remoteUpdatedAt.isAfter(localRow.updatedAt)) {
        await updateLocal(localRow.id, data);
      }
    }

    // Push (and tombstone cleanup): local rows never synced, locally
    // newer than their remote counterpart, or pending deletion.
    for (final row in localRows) {
      if (row.deletedAt != null) {
        if (row.remoteId != null) {
          await collection.doc(row.remoteId).delete();
        }
        await hardDeleteLocal(row.id);
        continue;
      }

      final remoteData = row.remoteId == null ? null : remoteDocs[row.remoteId];
      final remoteUpdatedAt = remoteData == null ? null : (remoteData['updatedAt'] as Timestamp).toDate();
      final needsPush = remoteUpdatedAt == null || row.updatedAt.isAfter(remoteUpdatedAt);
      if (!needsPush) continue;

      final docRef = row.remoteId == null ? collection.doc() : collection.doc(row.remoteId);
      await docRef.set({
        ...row.fields,
        'updatedAt': Timestamp.fromDate(row.updatedAt),
      }, SetOptions(merge: true));

      if (row.remoteId == null) {
        await setLocalRemoteId(row.id, docRef.id);
      }
    }
  }
}
