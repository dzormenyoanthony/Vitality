import '../../blood_pressure/domain/logging_streak.dart';

/// Which engagement notification (PROJECT_SPEC.md §23) a plan entry is for.
enum EngagementNotificationKind {
  /// The user has an active logging streak that hasn't been secured for
  /// today yet.
  streakAtRisk,

  /// A short-ish stretch with no reading at all — "ready to update your
  /// log?".
  missedTracking,

  /// A longer stretch with no reading — a lower-frequency nudge back into
  /// the app, distinct from [missedTracking] so the two never fire for the
  /// same gap in tracking.
  inactivity,
}

/// One notification this app state calls for, and when it should fire.
final class EngagementNotificationPlan {
  const EngagementNotificationPlan({
    required this.kind,
    required this.scheduledDate,
    this.streakCount = 0,
  });

  final EngagementNotificationKind kind;
  final DateTime scheduledDate;

  /// Only meaningful for [EngagementNotificationKind.streakAtRisk].
  final int streakCount;
}

/// How many full calendar days of inactivity trigger the shorter
/// "missed tracking" nudge.
const missedTrackingAfterDays = 3;

/// How many full calendar days of inactivity trigger the longer,
/// lower-frequency "inactivity" nudge. Deliberately far enough past
/// [missedTrackingAfterDays] that the two can never fall on the same day
/// for one gap in tracking (PROJECT_SPEC.md §23's anti-spam requirement).
const inactivityAfterDays = 10;

/// Decides which one-off engagement notifications should be scheduled right
/// now, from [streak] and the user's [preferredHour]/[preferredMinute] —
/// purely a function of already-computed state, no OS/plugin dependency, so
/// it's testable in isolation like `TrendCalculator`/`NextReminderCalculator`.
///
/// A notification kind absent from the result should be cancelled by the
/// caller — this function has no notion of what's already scheduled.
List<EngagementNotificationPlan> planEngagementNotifications({
  required StreakStats streak,
  required DateTime now,
  required int preferredHour,
  required int preferredMinute,
}) {
  final plans = <EngagementNotificationPlan>[];

  if (streak.isAtRisk) {
    final at = DateTime(now.year, now.month, now.day, preferredHour, preferredMinute);
    if (at.isAfter(now)) {
      plans.add(
        EngagementNotificationPlan(
          kind: EngagementNotificationKind.streakAtRisk,
          scheduledDate: at,
          streakCount: streak.currentStreak,
        ),
      );
    }
  }

  final lastActivity = streak.lastActivityDate;
  if (lastActivity != null) {
    final missedAt = DateTime(
      lastActivity.year,
      lastActivity.month,
      lastActivity.day + missedTrackingAfterDays,
      preferredHour,
      preferredMinute,
    );
    if (missedAt.isAfter(now)) {
      plans.add(
        EngagementNotificationPlan(kind: EngagementNotificationKind.missedTracking, scheduledDate: missedAt),
      );
    }

    final inactivityAt = DateTime(
      lastActivity.year,
      lastActivity.month,
      lastActivity.day + inactivityAfterDays,
      preferredHour,
      preferredMinute,
    );
    if (inactivityAt.isAfter(now)) {
      plans.add(
        EngagementNotificationPlan(kind: EngagementNotificationKind.inactivity, scheduledDate: inactivityAt),
      );
    }
  }

  return plans;
}
