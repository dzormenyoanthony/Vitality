import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';

import '../../../core/utils/logger.dart';
import '../../blood_pressure/data/app_database.dart';
import 'reminder.dart';
import 'reminder_repository.dart';

/// Local Drift storage for reminders, with an optional best-effort push to
/// Firestore after each write (PROJECT_SPEC.md §21-22). Sync is a no-op
/// when [firestore]/[currentUid] aren't supplied — existing local-only
/// callers and tests are unaffected. The bidirectional pull/reconcile pass
/// lives separately in `lib/core/sync/sync_coordinator.dart`; this class
/// only ever pushes what it just wrote (or deletes what it just
/// soft-deleted) — it never pulls.
class DriftReminderRepository implements ReminderRepository {
  DriftReminderRepository(this._db, {this.firestore, this.currentUid});

  final AppDatabase _db;
  final FirebaseFirestore? firestore;
  final String? Function()? currentUid;

  Set<int> _parseDays(String csv) =>
      csv.isEmpty ? <int>{} : csv.split(',').map(int.parse).toSet();

  String _formatDays(Set<int> days) => (days.toList()..sort()).join(',');

  Reminder _toDomain(ReminderRow row) {
    return Reminder(
      id: row.id,
      label: row.label,
      hour: row.hour,
      minute: row.minute,
      daysOfWeek: _parseDays(row.daysOfWeek),
      enabled: row.enabled,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  @override
  Stream<List<Reminder>> watchAll() {
    final query = _db.select(_db.reminders)
      ..where((r) => r.deletedAt.isNull())
      ..orderBy([(r) => OrderingTerm.asc(r.hour), (r) => OrderingTerm.asc(r.minute)]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Stream<Reminder?> watchById(int id) {
    final query = _db.select(_db.reminders)
      ..where((r) => r.id.equals(id) & r.deletedAt.isNull());
    return query.watchSingleOrNull().map((row) => row == null ? null : _toDomain(row));
  }

  @override
  Future<List<Reminder>> getAll() async {
    final rows = await (_db.select(
      _db.reminders,
    )..where((r) => r.deletedAt.isNull())).get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<int> addReminder({
    required String label,
    required int hour,
    required int minute,
    required Set<int> daysOfWeek,
    required bool enabled,
  }) async {
    final now = DateTime.now();
    final id = await _db
        .into(_db.reminders)
        .insert(
          RemindersCompanion.insert(
            label: label,
            hour: hour,
            minute: minute,
            daysOfWeek: _formatDays(daysOfWeek),
            enabled: Value(enabled),
            createdAt: now,
            updatedAt: now,
          ),
        );
    unawaited(_pushToFirestore(id));
    return id;
  }

  @override
  Future<void> updateReminder({
    required int id,
    required String label,
    required int hour,
    required int minute,
    required Set<int> daysOfWeek,
  }) async {
    await (_db.update(_db.reminders)..where((r) => r.id.equals(id))).write(
      RemindersCompanion(
        label: Value(label),
        hour: Value(hour),
        minute: Value(minute),
        daysOfWeek: Value(_formatDays(daysOfWeek)),
        updatedAt: Value(DateTime.now()),
      ),
    );
    unawaited(_pushToFirestore(id));
  }

  @override
  Future<void> setEnabled(int id, bool enabled) async {
    await (_db.update(_db.reminders)..where((r) => r.id.equals(id))).write(
      RemindersCompanion(enabled: Value(enabled), updatedAt: Value(DateTime.now())),
    );
    unawaited(_pushToFirestore(id));
  }

  @override
  Future<void> deleteReminder(int id) async {
    await (_db.update(_db.reminders)..where((r) => r.id.equals(id))).write(
      RemindersCompanion(deletedAt: Value(DateTime.now())),
    );
    unawaited(_pushToFirestore(id));
  }

  @override
  Future<void> deleteAll() {
    return _db.delete(_db.reminders).go();
  }

  /// Best-effort: pushes the current local state of [id] to Firestore (or
  /// deletes the remote doc if the row is soft-deleted), then reconciles
  /// the local row (writing back a new `remoteId`, or hard-deleting once a
  /// pending remote delete succeeds). Never throws — failures are logged
  /// and left for the next [SyncCoordinator] pass to retry.
  Future<void> _pushToFirestore(int id) async {
    final firestore = this.firestore;
    final uid = currentUid?.call();
    if (firestore == null || uid == null) return;

    try {
      final row = await (_db.select(
        _db.reminders,
      )..where((r) => r.id.equals(id))).getSingleOrNull();
      if (row == null) return;

      final collection = firestore.collection('users').doc(uid).collection('reminders');

      if (row.deletedAt != null) {
        if (row.remoteId != null) {
          await collection.doc(row.remoteId).delete();
        }
        await (_db.delete(_db.reminders)..where((r) => r.id.equals(id))).go();
        return;
      }

      final docRef = row.remoteId == null ? collection.doc() : collection.doc(row.remoteId);
      await docRef.set({
        'label': row.label,
        'hour': row.hour,
        'minute': row.minute,
        'daysOfWeek': row.daysOfWeek,
        'enabled': row.enabled,
        'createdAt': Timestamp.fromDate(row.createdAt),
        'updatedAt': Timestamp.fromDate(row.updatedAt),
      }, SetOptions(merge: true));

      if (row.remoteId == null) {
        await (_db.update(_db.reminders)..where((r) => r.id.equals(id))).write(
          RemindersCompanion(remoteId: Value(docRef.id)),
        );
      }
    } catch (error, stackTrace) {
      AppLogger.error('Failed to sync reminder $id to Firestore', error: error, stackTrace: stackTrace);
    }
  }
}
