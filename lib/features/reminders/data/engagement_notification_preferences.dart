import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/shared_preferences_provider.dart';
import 'engagement_notification_ids.dart';
import 'reminder_providers.dart';

const _streakRemindersKey = 'streak_reminders_enabled';
const _reEngagementNotificationsKey = 'reengagement_notifications_enabled';

/// Whether the "streak at risk" notification (PROJECT_SPEC.md §23-24) may
/// be scheduled. Off by default: like reminders (§17), notification
/// permission for this category is only requested once the user opts in
/// here, never eagerly on app start.
class StreakRemindersEnabledNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(sharedPreferencesProvider).getBool(_streakRemindersKey) ?? false;

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await ref.read(sharedPreferencesProvider).setBool(_streakRemindersKey, enabled);
    if (enabled) {
      await ref.read(notificationSchedulerProvider).requestPermission();
    } else {
      await ref.read(notificationSchedulerProvider).cancelById(EngagementNotificationIds.streakAtRisk);
    }
  }
}

final streakRemindersEnabledProvider = NotifierProvider<StreakRemindersEnabledNotifier, bool>(
  StreakRemindersEnabledNotifier.new,
);

/// Whether the missed-tracking / inactivity / weekly-summary re-engagement
/// notifications (PROJECT_SPEC.md §23-24) may be scheduled. Off by default,
/// same reasoning as [StreakRemindersEnabledNotifier].
class ReEngagementNotificationsEnabledNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(sharedPreferencesProvider).getBool(_reEngagementNotificationsKey) ?? false;

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await ref.read(sharedPreferencesProvider).setBool(_reEngagementNotificationsKey, enabled);
    if (enabled) {
      await ref.read(notificationSchedulerProvider).requestPermission();
    } else {
      final scheduler = ref.read(notificationSchedulerProvider);
      await scheduler.cancelById(EngagementNotificationIds.missedTracking);
      await scheduler.cancelById(EngagementNotificationIds.inactivity);
      await scheduler.cancelById(EngagementNotificationIds.weeklySummary);
    }
  }
}

final reEngagementNotificationsEnabledProvider =
    NotifierProvider<ReEngagementNotificationsEnabledNotifier, bool>(
      ReEngagementNotificationsEnabledNotifier.new,
    );
