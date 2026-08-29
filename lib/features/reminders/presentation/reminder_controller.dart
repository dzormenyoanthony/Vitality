import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/analytics/analytics_providers.dart';
import '../data/reminder_providers.dart';

/// Saves, enables/disables, and deletes reminders, orchestrating the
/// [ReminderRepository] write together with [NotificationScheduler]
/// scheduling. Permission is only requested when creating a new reminder
/// or enabling one (PROJECT_SPEC.md §17) — never on a plain edit of an
/// already-enabled reminder, which just reschedules.
class ReminderController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Pass [existingId] to update that reminder in place; omit it to
  /// create a new one (which starts enabled).
  Future<void> save({
    int? existingId,
    required String label,
    required int hour,
    required int minute,
    required Set<int> daysOfWeek,
    (int hour, int minute)? quietHoursStart,
    (int hour, int minute)? quietHoursEnd,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(reminderRepositoryProvider);
      final scheduler = ref.read(notificationSchedulerProvider);

      if (existingId == null) {
        final id = await repository.addReminder(
          label: label,
          hour: hour,
          minute: minute,
          daysOfWeek: daysOfWeek,
          enabled: true,
          quietHoursStart: quietHoursStart,
          quietHoursEnd: quietHoursEnd,
        );
        // PROJECT_SPEC.md §26 — a new reminder was created (not an edit).
        ref.read(analyticsServiceProvider).logReminderCreated();
        final granted = await scheduler.requestPermission();
        if (granted) {
          final reminder = await repository.watchById(id).first;
          if (reminder != null) await scheduler.scheduleReminder(reminder);
        }
      } else {
        await repository.updateReminder(
          id: existingId,
          label: label,
          hour: hour,
          minute: minute,
          daysOfWeek: daysOfWeek,
          quietHoursStart: quietHoursStart,
          quietHoursEnd: quietHoursEnd,
        );
        final reminder = await repository.watchById(existingId).first;
        if (reminder != null && reminder.enabled) {
          await scheduler.scheduleReminder(reminder);
        }
      }
    });
  }

  Future<void> setEnabled(int id, bool enabled) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(reminderRepositoryProvider);
      final scheduler = ref.read(notificationSchedulerProvider);
      await repository.setEnabled(id, enabled);

      if (!enabled) {
        await scheduler.cancelReminder(id);
        return;
      }
      final granted = await scheduler.requestPermission();
      if (granted) {
        final reminder = await repository.watchById(id).first;
        if (reminder != null) await scheduler.scheduleReminder(reminder);
      }
    });
  }

  Future<void> delete(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(notificationSchedulerProvider).cancelReminder(id);
      await ref.read(reminderRepositoryProvider).deleteReminder(id);
    });
  }
}

final reminderControllerProvider = AsyncNotifierProvider<ReminderController, void>(
  ReminderController.new,
);
