import 'blood_pressure_reading.dart';

/// Abstraction over local blood-pressure reading storage (Drift, per the
/// approved local-storage decision). Phase 6 layers Firestore sync behind
/// this same interface — no rework of callers when that happens.
abstract interface class BloodPressureRepository {
  /// All readings, newest first.
  Stream<List<BloodPressureReading>> watchAll();

  Stream<BloodPressureReading?> watchById(int id);

  Future<int> addReading({
    required int systolic,
    required int diastolic,
    int? pulse,
    required DateTime timestamp,
    String? notes,
    MeasurementContext? measurementContext,
  });

  Future<void> updateReading({
    required int id,
    required int systolic,
    required int diastolic,
    int? pulse,
    required DateTime timestamp,
    String? notes,
    MeasurementContext? measurementContext,
  });

  Future<void> deleteReading(int id);

  /// Deletes every reading. Used when deleting the account (PROJECT_SPEC.md
  /// §25) — local storage isn't partitioned per user, so this is a full wipe.
  Future<void> deleteAll();
}
