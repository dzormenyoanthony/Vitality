import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/logger.dart';
import '../../../l10n/app_localizations_en.dart';
import '../../blood_pressure/data/blood_pressure_providers.dart';
import '../../blood_pressure/domain/logging_streak.dart';
import '../domain/engagement_notification_plan.dart';
import 'engagement_notification_ids.dart';
import 'engagement_notification_preferences.dart';
import 'reminder.dart';
import 'reminder_providers.dart';

/// Recomputes and (re)schedules the streak-at-risk / missed-tracking /
/// inactivity / weekly-summary local notifications (PROJECT_SPEC.md §23)
/// from the latest readings, reminders, and notification-preference state.
///
/// Cheap and idempotent — every call fully replaces (or cancels) any
/// previously scheduled engagement notification, so nothing is ever
/// duplicated and state never drifts out of sync (the anti-spam
/// requirement). Meant to be called from app resume, sign-in, and right
/// after a reading is saved.
///
/// Vitaly ships a single locale (`lib/l10n/app_en.arb`), so notification
/// copy is built directly from [AppLocalizationsEn] rather than needing a
/// `BuildContext` — none is available at most of this class's call sites.
class EngagementNotificationCoordinator {
  EngagementNotificationCoordinator(this._ref);

  final Ref _ref;

  Future<void> reschedule() async {
    // Scheduling these notifications must never be able to break the
    // action that triggered a reschedule (saving a reading, resuming the
    // app) — degrade silently, matching NoOpPaywallService's philosophy
    // for a non-critical integration.
    try {
      await _reschedule();
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to reschedule engagement notifications',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _reschedule() async {
    final scheduler = _ref.read(notificationSchedulerProvider);
    final streakEnabled = _ref.read(streakRemindersEnabledProvider);
    final reEngagementEnabled = _ref.read(reEngagementNotificationsEnabledProvider);

    if (!streakEnabled) {
      await scheduler.cancelById(EngagementNotificationIds.streakAtRisk);
    }
    if (!reEngagementEnabled) {
      await scheduler.cancelById(EngagementNotificationIds.missedTracking);
      await scheduler.cancelById(EngagementNotificationIds.inactivity);
      await scheduler.cancelById(EngagementNotificationIds.weeklySummary);
    }
    if (!streakEnabled && !reEngagementEnabled) return;
    // Never prompts for permission itself (§17's "only when the user
    // creates/enables" applies here too) — just respects whatever the OS
    // currently allows.
    if (!await scheduler.areNotificationsEnabled()) return;

    final readings = await _ref.read(bloodPressureRepositoryProvider).getAll();
    final now = DateTime.now();
    final streak = computeStreakStats(readings, now);
    final reminders = await _ref.read(reminderRepositoryProvider).getAll();
    final (hour, minute) = _preferredTime(reminders);
    final l10n = AppLocalizationsEn();

    final plans = planEngagementNotifications(
      streak: streak,
      now: now,
      preferredHour: hour,
      preferredMinute: minute,
    );

    if (streakEnabled) {
      final risk = _planFor(plans, EngagementNotificationKind.streakAtRisk);
      if (risk != null) {
        await scheduler.scheduleOneOff(
          id: EngagementNotificationIds.streakAtRisk,
          title: l10n.streakAtRiskTitle,
          body: l10n.streakAtRiskBody(risk.streakCount),
          scheduledDate: risk.scheduledDate,
        );
      } else {
        await scheduler.cancelById(EngagementNotificationIds.streakAtRisk);
      }
    }

    if (reEngagementEnabled) {
      final missed = _planFor(plans, EngagementNotificationKind.missedTracking);
      if (missed != null) {
        await scheduler.scheduleOneOff(
          id: EngagementNotificationIds.missedTracking,
          title: l10n.missedTrackingTitle,
          body: l10n.missedTrackingBody,
          scheduledDate: missed.scheduledDate,
        );
      } else {
        await scheduler.cancelById(EngagementNotificationIds.missedTracking);
      }

      final inactivity = _planFor(plans, EngagementNotificationKind.inactivity);
      if (inactivity != null) {
        await scheduler.scheduleOneOff(
          id: EngagementNotificationIds.inactivity,
          title: l10n.inactivityReminderTitle,
          body: l10n.inactivityReminderBody,
          scheduledDate: inactivity.scheduledDate,
        );
      } else {
        await scheduler.cancelById(EngagementNotificationIds.inactivity);
      }

      if (readings.isNotEmpty) {
        await scheduler.scheduleWeekly(
          id: EngagementNotificationIds.weeklySummary,
          title: l10n.weeklySummaryTitle,
          body: l10n.weeklySummaryBody,
          weekday: DateTime.monday,
          hour: 9,
          minute: 0,
        );
      } else {
        await scheduler.cancelById(EngagementNotificationIds.weeklySummary);
      }
    }
  }

  EngagementNotificationPlan? _planFor(
    List<EngagementNotificationPlan> plans,
    EngagementNotificationKind kind,
  ) {
    for (final plan in plans) {
      if (plan.kind == kind) return plan;
    }
    return null;
  }

  /// The user's earliest enabled BP reminder time, if any — "use the
  /// user's configured reminder/notification preference where possible".
  /// Falls back to a sensible early-evening default so engagement
  /// notifications still respect reasonable hours when no reminder exists.
  (int, int) _preferredTime(List<Reminder> reminders) {
    final enabled = reminders.where((r) => r.enabled).toList()
      ..sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
    if (enabled.isEmpty) return (19, 0);
    return (enabled.first.hour, enabled.first.minute);
  }
}

final engagementNotificationCoordinatorProvider = Provider<EngagementNotificationCoordinator>((ref) {
  return EngagementNotificationCoordinator(ref);
});
