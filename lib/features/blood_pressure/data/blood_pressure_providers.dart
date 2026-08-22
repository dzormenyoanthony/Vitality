import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';
import 'blood_pressure_reading.dart';
import 'blood_pressure_repository.dart';
import 'drift_blood_pressure_repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Concrete [BloodPressureRepository] used by the running app. Tests
/// override this with a repository backed by an in-memory Drift database
/// instead of the on-disk one.
final bloodPressureRepositoryProvider = Provider<BloodPressureRepository>((ref) {
  return DriftBloodPressureRepository(ref.watch(appDatabaseProvider));
});

final readingsStreamProvider = StreamProvider<List<BloodPressureReading>>((ref) {
  return ref.watch(bloodPressureRepositoryProvider).watchAll();
});

final readingStreamProvider = StreamProvider.family<BloodPressureReading?, int>(
  (ref, id) => ref.watch(bloodPressureRepositoryProvider).watchById(id),
);
