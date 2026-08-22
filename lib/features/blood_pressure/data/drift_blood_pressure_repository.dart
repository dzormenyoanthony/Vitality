import 'package:drift/drift.dart';

import 'app_database.dart';
import 'blood_pressure_reading.dart';
import 'blood_pressure_repository.dart';

class DriftBloodPressureRepository implements BloodPressureRepository {
  DriftBloodPressureRepository(this._db);

  final AppDatabase _db;

  BloodPressureReading _toDomain(Reading row) {
    return BloodPressureReading(
      id: row.id,
      systolic: row.systolic,
      diastolic: row.diastolic,
      pulse: row.pulse,
      timestamp: row.timestamp,
      notes: row.notes,
      measurementContext: row.measurementContext == null
          ? null
          : MeasurementContext.values.byName(row.measurementContext!),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  @override
  Stream<List<BloodPressureReading>> watchAll() {
    final query = _db.select(_db.readings)
      ..orderBy([(r) => OrderingTerm.desc(r.timestamp)]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Stream<BloodPressureReading?> watchById(int id) {
    final query = _db.select(_db.readings)..where((r) => r.id.equals(id));
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _toDomain(row),
    );
  }

  @override
  Future<int> addReading({
    required int systolic,
    required int diastolic,
    int? pulse,
    required DateTime timestamp,
    String? notes,
    MeasurementContext? measurementContext,
  }) {
    final now = DateTime.now();
    return _db
        .into(_db.readings)
        .insert(
          ReadingsCompanion.insert(
            systolic: systolic,
            diastolic: diastolic,
            pulse: Value(pulse),
            timestamp: timestamp,
            notes: Value(notes),
            measurementContext: Value(measurementContext?.name),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  @override
  Future<void> updateReading({
    required int id,
    required int systolic,
    required int diastolic,
    int? pulse,
    required DateTime timestamp,
    String? notes,
    MeasurementContext? measurementContext,
  }) {
    return (_db.update(_db.readings)..where((r) => r.id.equals(id))).write(
      ReadingsCompanion(
        systolic: Value(systolic),
        diastolic: Value(diastolic),
        pulse: Value(pulse),
        timestamp: Value(timestamp),
        notes: Value(notes),
        measurementContext: Value(measurementContext?.name),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deleteReading(int id) {
    return (_db.delete(_db.readings)..where((r) => r.id.equals(id))).go();
  }
}
