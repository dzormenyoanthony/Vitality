import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/blood_pressure/data/app_database.dart';
import 'package:vitality/features/reminders/data/drift_reminder_repository.dart';

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
}
