import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/blood_pressure/data/app_database.dart';
import 'package:vitality/features/blood_pressure/data/blood_pressure_providers.dart';
import 'package:vitality/features/reminders/data/fake_notification_scheduler.dart';
import 'package:vitality/features/reminders/data/reminder.dart';
import 'package:vitality/features/reminders/data/reminder_providers.dart';
import 'package:vitality/features/reminders/presentation/reminder_controller.dart';

/// `container.read(streamProvider.future)` can return a stale cached value
/// instead of waiting for the next emission after a mutation (Drift's
/// watch-stream update arrives on a later microtask than the awaited
/// write). Polling the current value is the robust way to wait for a
/// specific post-mutation state — same pattern as
/// test/core/router/auth_gate_provider_test.dart.
Future<List<Reminder>> _waitFor(
  ProviderContainer container,
  bool Function(List<Reminder> reminders) condition, {
  Duration timeout = const Duration(seconds: 2),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (true) {
    final reminders = container.read(remindersStreamProvider).value ?? const [];
    if (condition(reminders)) return reminders;
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('Condition not met within $timeout');
    }
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}

void main() {
  late AppDatabase db;
  late FakeNotificationScheduler scheduler;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    scheduler = FakeNotificationScheduler();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        notificationSchedulerProvider.overrideWithValue(scheduler),
      ],
    );
    // Keeps remindersStreamProvider "warm" so reads reflect live state.
    container.listen(remindersStreamProvider, (_, _) {});
  });

  tearDown(() async {
    container.dispose();
    scheduler.dispose();
    await db.close();
  });

  test('creating a reminder saves it and schedules a notification', () async {
    await container
        .read(reminderControllerProvider.notifier)
        .save(label: 'Evening reading', hour: 20, minute: 0, daysOfWeek: {1, 2, 3, 4, 5});

    final reminders = await _waitFor(container, (r) => r.length == 1);
    expect(scheduler.scheduledReminderIds, contains(reminders.single.id));
  });

  test('creating a reminder still saves it if permission is denied', () async {
    scheduler.permissionGranted = false;

    await container
        .read(reminderControllerProvider.notifier)
        .save(label: 'Evening reading', hour: 20, minute: 0, daysOfWeek: {1});

    await _waitFor(container, (r) => r.length == 1);
    expect(scheduler.scheduledReminderIds, isEmpty);
  });

  test('editing a reminder reschedules it without re-requesting permission', () async {
    await container
        .read(reminderControllerProvider.notifier)
        .save(label: 'Original', hour: 8, minute: 0, daysOfWeek: {1});
    final id = (await _waitFor(container, (r) => r.length == 1)).single.id;

    scheduler.permissionGranted = false; // Would block a fresh request, but edit shouldn't ask.
    await container
        .read(reminderControllerProvider.notifier)
        .save(existingId: id, label: 'Updated', hour: 9, minute: 30, daysOfWeek: {1, 2});

    final updated = (await _waitFor(container, (r) => r.singleOrNull?.label == 'Updated')).single;
    expect(scheduler.scheduledReminderIds, contains(updated.id));
  });

  test('disabling a reminder cancels its schedule', () async {
    await container
        .read(reminderControllerProvider.notifier)
        .save(label: 'Reminder', hour: 8, minute: 0, daysOfWeek: {1});
    final id = (await _waitFor(container, (r) => r.length == 1)).single.id;
    expect(scheduler.scheduledReminderIds, contains(id));

    await container.read(reminderControllerProvider.notifier).setEnabled(id, false);
    await _waitFor(container, (r) => r.singleOrNull?.enabled == false);

    expect(scheduler.scheduledReminderIds, isNot(contains(id)));
  });

  test('deleting a reminder cancels its schedule and removes it', () async {
    await container
        .read(reminderControllerProvider.notifier)
        .save(label: 'Reminder', hour: 8, minute: 0, daysOfWeek: {1});
    final id = (await _waitFor(container, (r) => r.length == 1)).single.id;

    await container.read(reminderControllerProvider.notifier).delete(id);
    await _waitFor(container, (r) => r.isEmpty);

    expect(scheduler.scheduledReminderIds, isNot(contains(id)));
  });
}
