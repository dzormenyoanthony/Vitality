import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/blood_pressure/data/app_database.dart';
import 'package:vitality/features/blood_pressure/data/blood_pressure_reading.dart';
import 'package:vitality/features/blood_pressure/data/drift_blood_pressure_repository.dart';

/// `_pushToFirestore` is fire-and-forget, so tests that exercise it must
/// poll rather than assume it's finished by the time the awaited
/// repository call returns (same reasoning documented in
/// test/features/reminders/presentation/reminder_controller_test.dart).
Future<T> _waitFor<T>(
  Future<T> Function() read,
  bool Function(T value) condition, {
  Duration timeout = const Duration(seconds: 2),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (true) {
    final value = await read();
    if (condition(value)) return value;
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('Condition not met within $timeout');
    }
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}

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

  test('deleteReading soft-deletes without a Firestore configured: the row still exists', () async {
    final id = await repository.addReading(
      systolic: 120,
      diastolic: 80,
      timestamp: DateTime(2026, 1, 1),
    );

    await repository.deleteReading(id);

    final rawRow = await (db.select(db.readings)..where((r) => r.id.equals(id))).getSingle();
    expect(rawRow.deletedAt, isNotNull);
  });

  group('with Firestore configured', () {
    late FakeFirebaseFirestore firestore;
    late DriftBloodPressureRepository syncedRepository;
    const uid = 'test-uid';

    setUp(() {
      firestore = FakeFirebaseFirestore();
      syncedRepository = DriftBloodPressureRepository(db, firestore: firestore, currentUid: () => uid);
    });

    Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> remoteDocs() async {
      final snapshot = await firestore.collection('users').doc(uid).collection('readings').get();
      return snapshot.docs;
    }

    test('addReading pushes the new reading to Firestore', () async {
      await syncedRepository.addReading(
        systolic: 120,
        diastolic: 80,
        timestamp: DateTime(2026, 1, 1),
      );

      final docs = await _waitFor(() => remoteDocs(), (docs) => docs.isNotEmpty);
      expect(docs.single.data()['systolic'], 120);

      final row = await (db.select(db.readings)..limit(1)).getSingle();
      expect(row.remoteId, docs.single.id);
    });

    test('deleteReading removes the pushed reading from Firestore and hard-deletes locally', () async {
      final id = await syncedRepository.addReading(
        systolic: 120,
        diastolic: 80,
        timestamp: DateTime(2026, 1, 1),
      );
      await _waitFor(() => remoteDocs(), (docs) => docs.isNotEmpty);

      await syncedRepository.deleteReading(id);

      await _waitFor(() => remoteDocs(), (docs) => docs.isEmpty);
      final rows = await db.select(db.readings).get();
      expect(rows, isEmpty);
    });
  });
}
