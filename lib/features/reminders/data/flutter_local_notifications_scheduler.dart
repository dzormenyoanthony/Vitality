import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../domain/quiet_hours.dart';
import 'notification_scheduler.dart';
import 'reminder.dart';

const _channelId = 'bp_reminders';
const _channelName = 'Blood pressure reminders';
const _channelDescription = 'Reminders to record a blood pressure measurement';

/// Payload attached to every reminder notification, used to distinguish a
/// reminder tap from any other notification the app might show in future.
const _reminderPayload = 'record_bp_reminder';

/// Separate Android channel for the streak/re-engagement notifications
/// (PROJECT_SPEC.md §23) — a distinct channel from [_channelId] means
/// Android's own per-channel notification settings let a user mute this
/// category without touching their measurement reminders.
const _engagementChannelId = 'bp_engagement';
const _engagementChannelName = 'Vitaly activity reminders';
const _engagementChannelDescription =
    'Occasional streak and check-in reminders about your blood pressure tracking';

/// Real [NotificationScheduler] backed by `flutter_local_notifications`.
class FlutterLocalNotificationsScheduler implements NotificationScheduler {
  FlutterLocalNotificationsScheduler(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;
  final _tapController = StreamController<void>.broadcast();
  bool _initialized = false;

  /// Must be called once at app startup before scheduling/permission calls.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (response) {
        if (response.payload == _reminderPayload) _tapController.add(null);
      },
    );

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true &&
        launchDetails?.notificationResponse?.payload == _reminderPayload) {
      _tapController.add(null);
    }
  }

  @override
  Stream<void> get notificationTapped => _tapController.stream;

  @override
  Future<bool> requestPermission() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      return await androidPlugin.requestNotificationsPermission() ?? false;
    }
    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      return await iosPlugin.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    }
    return true;
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      return await androidPlugin.areNotificationsEnabled() ?? true;
    }
    return true;
  }

  @override
  Future<void> openNotificationSettings() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.openAppNotificationSettings();
  }

  @override
  Future<void> scheduleReminder(Reminder reminder) async {
    await cancelReminder(reminder.id);
    if (!reminder.enabled) return;

    // A reminder's fixed fire time may fall inside its own quiet-hours
    // window (computed once here, not re-checked at fire time) — deliver
    // silently instead of not firing at all.
    final silent = isWithinQuietHours(reminder);
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        playSound: !silent,
        enableVibration: !silent,
        silent: silent,
      ),
      iOS: DarwinNotificationDetails(presentSound: !silent),
    );

    for (final weekday in reminder.daysOfWeek) {
      await _plugin.zonedSchedule(
        id: _notificationId(reminder.id, weekday),
        title: reminder.label,
        body: 'Time to record your blood pressure.',
        scheduledDate: _nextInstanceOfWeekdayAndTime(weekday, reminder.hour, reminder.minute),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: _reminderPayload,
      );
    }
  }

  @override
  Future<void> cancelReminder(int reminderId) async {
    for (var weekday = 1; weekday <= 7; weekday++) {
      await _plugin.cancel(id: _notificationId(reminderId, weekday));
    }
  }

  @override
  Future<void> scheduleOneOff({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await cancelById(id);
    final scheduled = tz.TZDateTime.from(scheduledDate, tz.local);
    if (!scheduled.isAfter(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _engagementChannelId,
          _engagementChannelName,
          channelDescription: _engagementChannelDescription,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
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
    await cancelById(id);
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: _nextInstanceOfWeekdayAndTime(weekday, hour, minute),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _engagementChannelId,
          _engagementChannelName,
          channelDescription: _engagementChannelDescription,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  @override
  Future<void> cancelById(int id) => _plugin.cancel(id: id);

  int _notificationId(int reminderId, int weekday) => reminderId * 10 + weekday;

  tz.TZDateTime _nextInstanceOfWeekdayAndTime(int weekday, int hour, int minute) {
    var scheduled = tz.TZDateTime.now(tz.local);
    scheduled = tz.TZDateTime(
      tz.local,
      scheduled.year,
      scheduled.month,
      scheduled.day,
      hour,
      minute,
    );
    while (scheduled.weekday != weekday || scheduled.isBefore(tz.TZDateTime.now(tz.local))) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
