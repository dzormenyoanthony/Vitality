import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../blood_pressure/data/blood_pressure_providers.dart';
import 'drift_reminder_repository.dart';
import 'flutter_local_notifications_scheduler.dart';
import 'notification_scheduler.dart';
import 'reminder.dart';
import 'reminder_repository.dart';

/// Concrete [ReminderRepository] used by the running app. Tests override
/// this with a repository backed by an in-memory Drift database.
final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return DriftReminderRepository(ref.watch(appDatabaseProvider));
});

final remindersStreamProvider = StreamProvider<List<Reminder>>((ref) {
  return ref.watch(reminderRepositoryProvider).watchAll();
});

final reminderStreamProvider = StreamProvider.family<Reminder?, int>(
  (ref, id) => ref.watch(reminderRepositoryProvider).watchById(id),
);

/// Concrete [NotificationScheduler] used by the running app. Must be
/// initialized once (see [FlutterLocalNotificationsScheduler.initialize])
/// during app startup before use — tests override this provider entirely
/// with a [FakeNotificationScheduler] instead.
final notificationSchedulerProvider = Provider<NotificationScheduler>((ref) {
  return FlutterLocalNotificationsScheduler(FlutterLocalNotificationsPlugin());
});

/// Whether the OS currently allows Vitaly to show notifications — powers
/// the Reminders screen's "system notifications are switched off"
/// warning. Re-check by invalidating this provider (e.g. after the user
/// returns from the OS settings screen).
final notificationsEnabledProvider = FutureProvider<bool>((ref) {
  return ref.watch(notificationSchedulerProvider).areNotificationsEnabled();
});
