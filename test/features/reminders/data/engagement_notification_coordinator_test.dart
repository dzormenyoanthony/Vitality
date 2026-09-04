import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vitality/core/services/shared_preferences_provider.dart';
import 'package:vitality/features/blood_pressure/data/app_database.dart';
import 'package:vitality/features/blood_pressure/data/blood_pressure_providers.dart';
import 'package:vitality/features/reminders/data/engagement_notification_coordinator.dart';
import 'package:vitality/features/reminders/data/engagement_notification_ids.dart';
import 'package:vitality/features/reminders/data/engagement_notification_preferences.dart';
import 'package:vitality/features/reminders/data/fake_notification_scheduler.dart';
import 'package:vitality/features/reminders/data/reminder_providers.dart';

void main() {
  late AppDatabase db;
  late FakeNotificationScheduler scheduler;
  late ProviderContainer container;

  Future<void> buildContainer(Map<String, Object> prefsValues) async {
    SharedPreferences.setMockInitialValues(prefsValues);
    final prefs = await SharedPreferences.getInstance();
    db = AppDatabase(NativeDatabase.memory());
    scheduler = FakeNotificationScheduler();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        notificationSchedulerProvider.overrideWithValue(scheduler),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
  }

  tearDown(() async {
    container.dispose();
    scheduler.dispose();
    await db.close();
  });

  /// The coordinator's preferred notification time defaults to a fixed
  /// 19:00 fallback when there's no enabled reminder to read it from — to
  /// keep "later today" assertions below deterministic regardless of what
  /// time the suite actually runs at, give it an enabled reminder a few
  /// minutes in the future instead.
  Future<void> addNearFutureReminder() async {
    final soon = DateTime.now().add(const Duration(minutes: 5));
    await container
        .read(reminderRepositoryProvider)
        .addReminder(
          label: 'Test reminder',
          hour: soon.hour,
          minute: soon.minute,
          daysOfWeek: const {1, 2, 3, 4, 5, 6, 7},
          enabled: true,
        );
  }

  test('schedules nothing when both notification categories are disabled (the default)', () async {
    await buildContainer({});
    await container
        .read(bloodPressureRepositoryProvider)
        .addReading(
          systolic: 120,
          diastolic: 80,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        );

    await container.read(engagementNotificationCoordinatorProvider).reschedule();

    expect(scheduler.scheduledEngagementNotifications, isEmpty);
  });

  test('schedules a streak-at-risk notification once enabled, with an active at-risk streak', () async {
    await buildContainer({'streak_reminders_enabled': true});
    await addNearFutureReminder();
    final now = DateTime.now();
    await container.read(bloodPressureRepositoryProvider).addReading(
      systolic: 120,
      diastolic: 80,
      timestamp: now.subtract(const Duration(days: 1)),
    );

    await container.read(engagementNotificationCoordinatorProvider).reschedule();

    expect(
      scheduler.scheduledEngagementNotifications.containsKey(EngagementNotificationIds.streakAtRisk),
      isTrue,
    );
  });

  test('does not schedule a streak-at-risk notification once today is already recorded', () async {
    await buildContainer({'streak_reminders_enabled': true});
    await addNearFutureReminder();
    final now = DateTime.now();
    await container.read(bloodPressureRepositoryProvider).addReading(
      systolic: 120,
      diastolic: 80,
      timestamp: now.subtract(const Duration(days: 1)),
    );
    await container.read(bloodPressureRepositoryProvider).addReading(
      systolic: 118,
      diastolic: 78,
      timestamp: now,
    );

    await container.read(engagementNotificationCoordinatorProvider).reschedule();

    expect(
      scheduler.scheduledEngagementNotifications.containsKey(EngagementNotificationIds.streakAtRisk),
      isFalse,
    );
  });

  test('disabling streak reminders cancels a previously scheduled streak-at-risk notification', () async {
    await buildContainer({'streak_reminders_enabled': true});
    await addNearFutureReminder();
    final now = DateTime.now();
    await container.read(bloodPressureRepositoryProvider).addReading(
      systolic: 120,
      diastolic: 80,
      timestamp: now.subtract(const Duration(days: 1)),
    );
    await container.read(engagementNotificationCoordinatorProvider).reschedule();
    expect(
      scheduler.scheduledEngagementNotifications.containsKey(EngagementNotificationIds.streakAtRisk),
      isTrue,
    );

    await container.read(streakRemindersEnabledProvider.notifier).setEnabled(false);
    await container.read(engagementNotificationCoordinatorProvider).reschedule();

    expect(scheduler.scheduledEngagementNotifications, isEmpty);
  });

  test('respects system notification permission being denied', () async {
    await buildContainer({'streak_reminders_enabled': true, 'reengagement_notifications_enabled': true});
    scheduler.notificationsEnabled = false;
    final now = DateTime.now();
    await container.read(bloodPressureRepositoryProvider).addReading(
      systolic: 120,
      diastolic: 80,
      timestamp: now.subtract(const Duration(days: 1)),
    );

    await container.read(engagementNotificationCoordinatorProvider).reschedule();

    expect(scheduler.scheduledEngagementNotifications, isEmpty);
  });

  test('re-engagement toggle schedules a weekly summary once there is at least one reading', () async {
    await buildContainer({'reengagement_notifications_enabled': true});
    await container
        .read(bloodPressureRepositoryProvider)
        .addReading(systolic: 120, diastolic: 80, timestamp: DateTime.now());

    await container.read(engagementNotificationCoordinatorProvider).reschedule();

    expect(
      scheduler.scheduledEngagementNotifications.containsKey(EngagementNotificationIds.weeklySummary),
      isTrue,
    );
  });

  test('never throws even if reading shared preferences fails (degrades silently)', () async {
    // No sharedPreferencesProvider override at all — reading it throws.
    db = AppDatabase(NativeDatabase.memory());
    scheduler = FakeNotificationScheduler();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        notificationSchedulerProvider.overrideWithValue(scheduler),
      ],
    );

    await expectLater(
      container.read(engagementNotificationCoordinatorProvider).reschedule(),
      completes,
    );
  });
}
