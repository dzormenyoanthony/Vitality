import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/blood_pressure/data/app_database.dart';
import 'package:vitality/features/blood_pressure/data/blood_pressure_reading.dart';
import 'package:vitality/features/blood_pressure/data/drift_blood_pressure_repository.dart';

void main() {
  late AppDatabase db;
  late DriftBloodPressureRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = DriftBloodPressureRepository(db);
  });

  tearDown(() => db.close());

  test('addReading makes the reading appear in watchAll', () async {
    final id = await repository.addReading(
      systolic: 120,
      diastolic: 80,
      pulse: 70,
      timestamp: DateTime(2026, 1, 1, 8),
      notes: 'Felt fine',
      measurementContext: MeasurementContext.morning,
    );

    final readings = await repository.watchAll().first;

    expect(readings, hasLength(1));
    expect(readings.single.id, id);
    expect(readings.single.systolic, 120);
    expect(readings.single.diastolic, 80);
    expect(readings.single.pulse, 70);
    expect(readings.single.notes, 'Felt fine');
    expect(readings.single.measurementContext, MeasurementContext.morning);
  });

  test('watchAll orders readings newest first', () async {
    await repository.addReading(
      systolic: 110,
      diastolic: 70,
      timestamp: DateTime(2026, 1, 1),
    );
    await repository.addReading(
      systolic: 130,
      diastolic: 85,
      timestamp: DateTime(2026, 1, 3),
    );
    await repository.addReading(
      systolic: 120,
      diastolic: 80,
      timestamp: DateTime(2026, 1, 2),
    );

    final readings = await repository.watchAll().first;

    expect(readings.map((r) => r.systolic).toList(), [130, 120, 110]);
  });

  test('updateReading changes the stored values but keeps the id', () async {
    final id = await repository.addReading(
      systolic: 120,
      diastolic: 80,
      timestamp: DateTime(2026, 1, 1),
    );

    await repository.updateReading(
      id: id,
      systolic: 118,
      diastolic: 76,
      pulse: 65,
      timestamp: DateTime(2026, 1, 1),
      measurementContext: MeasurementContext.evening,
    );

    final updated = await repository.watchById(id).first;

    expect(updated, isNotNull);
    expect(updated!.id, id);
    expect(updated.systolic, 118);
    expect(updated.diastolic, 76);
    expect(updated.pulse, 65);
    expect(updated.measurementContext, MeasurementContext.evening);
  });

  test('deleteReading removes it from watchAll and watchById', () async {
    final id = await repository.addReading(
      systolic: 120,
      diastolic: 80,
      timestamp: DateTime(2026, 1, 1),
    );

    await repository.deleteReading(id);

    expect(await repository.watchAll().first, isEmpty);
    expect(await repository.watchById(id).first, isNull);
  });
}
