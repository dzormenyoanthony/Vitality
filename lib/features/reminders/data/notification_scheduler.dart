import 'reminder.dart';

/// Abstraction over OS-level reminder notification scheduling
/// (PROJECT_SPEC.md §17). Kept separate from [ReminderRepository] — this
/// deals with the device's notification system, not persistence.
abstract interface class NotificationScheduler {
  /// Requests notification permission. Per §17, this must only be called
  /// when the user creates or enables a reminder — never eagerly on app
  /// start. Returns whether permission is granted.
  Future<bool> requestPermission();

  /// Schedules one recurring notification per selected weekday in
  /// [Reminder.daysOfWeek]. Safe to call again for the same reminder (e.g.
  /// after editing) — replaces any existing schedule for it.
  Future<void> scheduleReminder(Reminder reminder);

  /// Cancels all scheduled notifications for [reminderId], if any.
  Future<void> cancelReminder(int reminderId);

  /// Emits whenever a reminder notification is tapped — covers both a
  /// warm tap (app already running) and a cold start (app launched by
  /// tapping the notification, surfaced once at startup).
  Stream<void> get notificationTapped;
}
