import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';

import '../../../core/utils/logger.dart';
import 'app_database.dart';
import 'blood_pressure_reading.dart';
import 'blood_pressure_repository.dart';

/// Local Drift storage for readings, with an optional best-effort push to
/// Firestore after each write (PROJECT_SPEC.md §21-22). Sync is a no-op
/// when [firestore]/[currentUid] aren't supplied — existing local-only
/// callers and tests are unaffected. The bidirectional pull/reconcile pass
/// lives separately in `lib/core/sync/sync_coordinator.dart`; this class
/// only ever pushes what it just wrote (or deletes what it just
/// soft-deleted) — it never pulls.
class DriftBloodPressureRepository implements BloodPressureRepository {
  DriftBloodPressureRepository(this._db, {this.firestore, this.currentUid});

  final AppDatabase _db;
  final FirebaseFirestore? firestore;
  final String? Function()? currentUid;

  List<MeasurementContext> _parseContexts(String? csv) =>
      csv == null || csv.isEmpty
      ? const []
      : csv.split(',').map(MeasurementContext.values.byName).toList();

  String? _formatContexts(List<MeasurementContext> contexts) =>
      contexts.isEmpty ? null : contexts.map((c) => c.name).join(',');

  BloodPressureReading _toDomain(Reading row) {
    return BloodPressureReading(
      id: row.id,
      systolic: row.systolic,
      diastolic: row.diastolic,
      pulse: row.pulse,
      timestamp: row.timestamp,
      notes: row.notes,
      measurementContexts: _parseContexts(row.measurementContexts),
      bodyPosition: row.bodyPosition == null
          ? null
          : BodyPosition.values.byName(row.bodyPosition!),
      cuffArm: row.cuffArm == null ? null : CuffArm.values.byName(row.cuffArm!),
      source: ReadingSource.values.byName(row.source),
      sourceReportId: row.sourceReportId,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  @override
  Stream<List<BloodPressureReading>> watchAll() {
    final query = _db.select(_db.readings)
      ..where((r) => r.deletedAt.isNull())
      ..orderBy([(r) => OrderingTerm.desc(r.timestamp)]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Stream<BloodPressureReading?> watchById(int id) {
    final query = _db.select(_db.readings)
      ..where((r) => r.id.equals(id) & r.deletedAt.isNull());
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _toDomain(row),
    );
  }

  @override
  Future<List<BloodPressureReading>> getAll() async {
    final query = _db.select(_db.readings)
      ..where((r) => r.deletedAt.isNull())
      ..orderBy([(r) => OrderingTerm.desc(r.timestamp)]);
    final rows = await query.get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<int> addReading({
    required int systolic,
    required int diastolic,
    int? pulse,
    required DateTime timestamp,
    String? notes,
    List<MeasurementContext> measurementContexts = const [],
    BodyPosition? bodyPosition,
    CuffArm? cuffArm,
    ReadingSource source = ReadingSource.manual,
    int? sourceReportId,
  }) async {
    final now = DateTime.now();
    final id = await _db
        .into(_db.readings)
        .insert(
          ReadingsCompanion.insert(
            systolic: systolic,
            diastolic: diastolic,
            pulse: Value(pulse),
            timestamp: timestamp,
            notes: Value(notes),
            measurementContexts: Value(_formatContexts(measurementContexts)),
            bodyPosition: Value(bodyPosition?.name),
            cuffArm: Value(cuffArm?.name),
            source: Value(source.name),
            sourceReportId: Value(sourceReportId),
            createdAt: now,
            updatedAt: now,
          ),
        );
    unawaited(_pushToFirestore(id));
    return id;
  }

  @override
  Future<void> updateReading({
    required int id,
    required int systolic,
    required int diastolic,
    int? pulse,
    required DateTime timestamp,
    String? notes,
    List<MeasurementContext> measurementContexts = const [],
    BodyPosition? bodyPosition,
    CuffArm? cuffArm,
  }) async {
    await (_db.update(_db.readings)..where((r) => r.id.equals(id))).write(
      ReadingsCompanion(
        systolic: Value(systolic),
        diastolic: Value(diastolic),
        pulse: Value(pulse),
        timestamp: Value(timestamp),
        notes: Value(notes),
        measurementContexts: Value(_formatContexts(measurementContexts)),
        bodyPosition: Value(bodyPosition?.name),
        cuffArm: Value(cuffArm?.name),
        updatedAt: Value(DateTime.now()),
      ),
    );
    unawaited(_pushToFirestore(id));
  }

  @override
  Future<void> deleteReading(int id) async {
    await (_db.update(_db.readings)..where((r) => r.id.equals(id))).write(
      ReadingsCompanion(deletedAt: Value(DateTime.now())),
    );
    unawaited(_pushToFirestore(id));
  }

  @override
  Future<void> deleteAll() {
    return _db.delete(_db.readings).go();
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
        _db.readings,
      )..where((r) => r.id.equals(id))).getSingleOrNull();
      if (row == null) return;

      final collection = firestore.collection('users').doc(uid).collection('readings');

      if (row.deletedAt != null) {
        if (row.remoteId != null) {
          await collection.doc(row.remoteId).delete();
        }
        await (_db.delete(_db.readings)..where((r) => r.id.equals(id))).go();
        return;
      }

      final docRef = row.remoteId == null ? collection.doc() : collection.doc(row.remoteId);
      await docRef.set({
        'systolic': row.systolic,
        'diastolic': row.diastolic,
        'pulse': row.pulse,
        'timestamp': Timestamp.fromDate(row.timestamp),
        'notes': row.notes,
        'measurementContexts': row.measurementContexts,
        'bodyPosition': row.bodyPosition,
        'cuffArm': row.cuffArm,
        'source': row.source,
        'sourceReportId': row.sourceReportId,
        'createdAt': Timestamp.fromDate(row.createdAt),
        'updatedAt': Timestamp.fromDate(row.updatedAt),
      }, SetOptions(merge: true));

      if (row.remoteId == null) {
        await (_db.update(_db.readings)..where((r) => r.id.equals(id))).write(
          ReadingsCompanion(remoteId: Value(docRef.id)),
        );
      }
    } catch (error, stackTrace) {
      AppLogger.error('Failed to sync reading $id to Firestore', error: error, stackTrace: stackTrace);
    }
  }
}
