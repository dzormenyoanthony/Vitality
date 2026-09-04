import 'reminder.dart';

/// Abstraction over OS-level reminder notification scheduling
/// (PROJECT_SPEC.md §17). Kept separate from [ReminderRepository] — this
/// deals with the device's notification system, not persistence.
abstract interface class NotificationScheduler {
  /// Requests notification permission. Per §17, this must only be called
  /// when the user creates or enables a reminder — never eagerly on app
  /// start. Returns whether permission is granted.
  Future<bool> requestPermission();

  /// Checks (without prompting) whether notifications are currently
  /// enabled for this app at the OS level — powers the Reminders screen's
  /// "system notifications are switched off" warning. Defaults to `true`
  /// on platforms without a check-only API (this app's primary target is
  /// Android, where the check is real).
  Future<bool> areNotificationsEnabled();

  /// Opens the OS notification settings screen for this app, if the
  /// platform supports it.
  Future<void> openNotificationSettings();

  /// Schedules one recurring notification per selected weekday in
  /// [Reminder.daysOfWeek]. Safe to call again for the same reminder (e.g.
  /// after editing) — replaces any existing schedule for it.
  Future<void> scheduleReminder(Reminder reminder);

  /// Cancels all scheduled notifications for [reminderId], if any.
  Future<void> cancelReminder(int reminderId);

  /// Schedules a one-shot local notification at [scheduledDate] (local
  /// time; must be in the future or this is a no-op), replacing any
  /// previously scheduled notification under [id]. Used for the dynamic
  /// engagement notifications (streak-at-risk, missed-tracking, inactivity
  /// — PROJECT_SPEC.md §23) whose content is computed from current app
  /// state, unlike the fixed recurring content of [scheduleReminder].
  Future<void> scheduleOneOff({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  });

  /// Schedules a recurring weekly notification (e.g. the weekly summary),
  /// replacing any previous schedule under [id].
  Future<void> scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required int weekday,
    required int hour,
    required int minute,
  });

  /// Cancels a notification previously scheduled via [scheduleOneOff] or
  /// [scheduleWeekly].
  Future<void> cancelById(int id);

  /// Emits whenever a reminder notification is tapped — covers both a
  /// warm tap (app already running) and a cold start (app launched by
  /// tapping the notification, surfaced once at startup).
  Stream<void> get notificationTapped;
}
