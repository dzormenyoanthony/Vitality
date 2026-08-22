import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/blood_pressure/data/app_database.dart';
import 'package:vitality/features/reminders/data/drift_reminder_repository.dart';

/// `_pushToFirestore` is fire-and-forget, so tests that exercise it must
/// poll rather than assume it's finished by the time the awaited
/// repository call returns.
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
  late DriftReminderRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = DriftReminderRepository(db);
  });

  tearDown(() => db.close());

  test('addReminder makes it appear in watchAll', () async {
    final id = await repository.addReminder(
      label: 'Morning reading',
      hour: 8,
      minute: 30,
      daysOfWeek: {1, 3, 5},
      enabled: true,
    );

    final reminders = await repository.watchAll().first;

    expect(reminders, hasLength(1));
    expect(reminders.single.id, id);
    expect(reminders.single.label, 'Morning reading');
    expect(reminders.single.hour, 8);
    expect(reminders.single.minute, 30);
    expect(reminders.single.daysOfWeek, {1, 3, 5});
    expect(reminders.single.enabled, isTrue);
  });

  test('round-trips every day of the week correctly', () async {
    await repository.addReminder(
      label: 'Every day',
      hour: 7,
      minute: 0,
      daysOfWeek: {1, 2, 3, 4, 5, 6, 7},
      enabled: true,
    );

    final reminders = await repository.watchAll().first;

    expect(reminders.single.daysOfWeek, {1, 2, 3, 4, 5, 6, 7});
  });

  test('updateReminder changes the stored values', () async {
    final id = await repository.addReminder(
      label: 'Original',
      hour: 8,
      minute: 0,
      daysOfWeek: {1},
      enabled: true,
    );

    await repository.updateReminder(
      id: id,
      label: 'Updated',
      hour: 20,
      minute: 15,
      daysOfWeek: {6, 7},
    );

    final updated = await repository.watchById(id).first;

    expect(updated!.label, 'Updated');
    expect(updated.hour, 20);
    expect(updated.minute, 15);
    expect(updated.daysOfWeek, {6, 7});
  });

  test('setEnabled toggles the enabled flag without touching other fields', () async {
    final id = await repository.addReminder(
      label: 'Reminder',
      hour: 9,
      minute: 0,
      daysOfWeek: {1},
      enabled: true,
    );

    await repository.setEnabled(id, false);
    final disabled = await repository.watchById(id).first;
    expect(disabled!.enabled, isFalse);
    expect(disabled.label, 'Reminder');

    await repository.setEnabled(id, true);
    final enabled = await repository.watchById(id).first;
    expect(enabled!.enabled, isTrue);
  });

  test('deleteReminder removes it from watchAll and watchById', () async {
    final id = await repository.addReminder(
      label: 'Reminder',
      hour: 9,
      minute: 0,
      daysOfWeek: {1},
      enabled: true,
    );

    await repository.deleteReminder(id);

    expect(await repository.watchAll().first, isEmpty);
    expect(await repository.watchById(id).first, isNull);
  });

  group('with Firestore configured', () {
    late FakeFirebaseFirestore firestore;
    late DriftReminderRepository syncedRepository;
    const uid = 'test-uid';

    setUp(() {
      firestore = FakeFirebaseFirestore();
      syncedRepository = DriftReminderRepository(db, firestore: firestore, currentUid: () => uid);
    });

    Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> remoteDocs() async {
      final snapshot = await firestore.collection('users').doc(uid).collection('reminders').get();
      return snapshot.docs;
    }

    test('addReminder pushes the new reminder to Firestore', () async {
      await syncedRepository.addReminder(
        label: 'Evening check',
        hour: 18,
        minute: 30,
        daysOfWeek: {1, 2, 3, 4, 5},
        enabled: true,
      );

      final docs = await _waitFor(() => remoteDocs(), (docs) => docs.isNotEmpty);
      expect(docs.single.data()['label'], 'Evening check');

      final row = await (db.select(db.reminders)..limit(1)).getSingle();
      expect(row.remoteId, docs.single.id);
    });

    test('deleteReminder removes the pushed reminder from Firestore and hard-deletes locally', () async {
      final id = await syncedRepository.addReminder(
        label: 'Evening check',
        hour: 18,
        minute: 30,
        daysOfWeek: {1},
        enabled: true,
      );
      await _waitFor(() => remoteDocs(), (docs) => docs.isNotEmpty);

      await syncedRepository.deleteReminder(id);

      await _waitFor(() => remoteDocs(), (docs) => docs.isEmpty);
      final rows = await db.select(db.reminders).get();
      expect(rows, isEmpty);
    });
  });
}
