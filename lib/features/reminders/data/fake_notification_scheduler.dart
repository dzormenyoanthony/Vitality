import 'dart:async';

import 'notification_scheduler.dart';
import 'reminder.dart';

/// In-memory [NotificationScheduler] used in tests. Records what was
/// scheduled/cancelled instead of touching platform channels.
class FakeNotificationScheduler implements NotificationScheduler {
  final _tapController = StreamController<void>.broadcast();

  bool permissionGranted = true;
  bool notificationsEnabled = true;
  int openNotificationSettingsCallCount = 0;
  final Set<int> scheduledReminderIds = {};

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
  Stream<void> get notificationTapped => _tapController.stream;

  void simulateNotificationTapped() => _tapController.add(null);

  void dispose() => _tapController.close();
}
