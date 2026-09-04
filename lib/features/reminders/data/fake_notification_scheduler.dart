import 'dart:async';

import 'notification_scheduler.dart';
import 'reminder.dart';

/// A one-off or weekly notification recorded by [FakeNotificationScheduler],
/// for tests to assert on.
final class ScheduledEngagementNotification {
  const ScheduledEngagementNotification({
    required this.title,
    required this.body,
    required this.scheduledDate,
  });

  final String title;
  final String body;
  final DateTime scheduledDate;
}

/// In-memory [NotificationScheduler] used in tests. Records what was
/// scheduled/cancelled instead of touching platform channels.
class FakeNotificationScheduler implements NotificationScheduler {
  final _tapController = StreamController<void>.broadcast();

  bool permissionGranted = true;
  bool notificationsEnabled = true;
  int openNotificationSettingsCallCount = 0;
  final Set<int> scheduledReminderIds = {};

  /// Keyed by the `id` passed to [scheduleOneOff]/[scheduleWeekly]; removed
  /// by [cancelById]. Weekly entries are recorded with the same shape, just
  /// without a meaningful [ScheduledEngagementNotification.scheduledDate]
  /// beyond "the next occurrence".
  final Map<int, ScheduledEngagementNotification> scheduledEngagementNotifications = {};

  @override
  Future<bool> requestPermission() async => permissionGranted;

  @override
  Future<bool> areNotificationsEnabled() async => notificationsEnabled;

  @override
  Future<void> openNotificationSettings() async {
    openNotificationSettingsCallCount++;
  }

  @override
  Future<void> scheduleReminder(Reminder reminder) async {
    if (reminder.enabled) {
      scheduledReminderIds.add(reminder.id);
    } else {
      scheduledReminderIds.remove(reminder.id);
    }
  }

  @override
  Future<void> cancelReminder(int reminderId) async {
    scheduledReminderIds.remove(reminderId);
  }

  @override
  Future<void> scheduleOneOff({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (!scheduledDate.isAfter(DateTime.now())) {
      scheduledEngagementNotifications.remove(id);
      return;
    }
    scheduledEngagementNotifications[id] = ScheduledEngagementNotification(
      title: title,
      body: body,
      scheduledDate: scheduledDate,
    );
  }

  @override
  Future<void> scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required int weekday,
    required int hour,
    required int minute,
  }) async {
    scheduledEngagementNotifications[id] = ScheduledEngagementNotification(
      title: title,
      body: body,
      scheduledDate: DateTime(0, 0, weekday, hour, minute),
    );
  }

  @override
  Future<void> cancelById(int id) async {
    scheduledEngagementNotifications.remove(id);
  }

  @override
  Stream<void> get notificationTapped => _tapController.stream;

  void simulateNotificationTapped() => _tapController.add(null);

  void dispose() => _tapController.close();
}
