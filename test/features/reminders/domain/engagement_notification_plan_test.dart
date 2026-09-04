import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/blood_pressure/domain/logging_streak.dart';
import 'package:vitality/features/reminders/domain/engagement_notification_plan.dart';

void main() {
  test('plans nothing when there is no streak and no reading history', () {
    final plans = planEngagementNotifications(
      streak: StreakStats.empty,
      now: DateTime(2026, 9, 4, 8),
      preferredHour: 19,
      preferredMinute: 0,
    );
    expect(plans, isEmpty);
  });

  test('plans a streak-at-risk notification for later today when the streak is at risk', () {
    final streak = StreakStats(
      currentStreak: 5,
      bestStreak: 5,
      lastActivityDate: DateTime(2026, 9, 3),
      recordedToday: false,
    );
    final plans = planEngagementNotifications(
      streak: streak,
      now: DateTime(2026, 9, 4, 8),
      preferredHour: 19,
      preferredMinute: 0,
    );

    final risk = plans.singleWhere((p) => p.kind == EngagementNotificationKind.streakAtRisk);
    expect(risk.scheduledDate, DateTime(2026, 9, 4, 19, 0));
    expect(risk.streakCount, 5);
  });

  test('does not plan a streak-at-risk notification once the preferred time has already passed today', () {
    final streak = StreakStats(
      currentStreak: 5,
      bestStreak: 5,
      lastActivityDate: DateTime(2026, 9, 3),
      recordedToday: false,
    );
    final plans = planEngagementNotifications(
      streak: streak,
      now: DateTime(2026, 9, 4, 20),
      preferredHour: 19,
      preferredMinute: 0,
    );

    expect(plans.any((p) => p.kind == EngagementNotificationKind.streakAtRisk), isFalse);
  });

  test('does not plan a streak-at-risk notification once today is already recorded', () {
    final streak = StreakStats(
      currentStreak: 5,
      bestStreak: 5,
      lastActivityDate: DateTime(2026, 9, 4),
      recordedToday: true,
    );
    final plans = planEngagementNotifications(
      streak: streak,
      now: DateTime(2026, 9, 4, 8),
      preferredHour: 19,
      preferredMinute: 0,
    );

    expect(plans.any((p) => p.kind == EngagementNotificationKind.streakAtRisk), isFalse);
  });

  test('plans missed-tracking and inactivity notifications ahead of a still-open gap', () {
    final streak = StreakStats(
      currentStreak: 0,
      bestStreak: 3,
      lastActivityDate: DateTime(2026, 9, 1),
      recordedToday: false,
    );
    final plans = planEngagementNotifications(
      streak: streak,
      now: DateTime(2026, 9, 2, 8),
      preferredHour: 10,
      preferredMinute: 0,
    );

    final missed = plans.singleWhere((p) => p.kind == EngagementNotificationKind.missedTracking);
    expect(missed.scheduledDate, DateTime(2026, 9, 4, 10, 0));

    final inactivity = plans.singleWhere((p) => p.kind == EngagementNotificationKind.inactivity);
    expect(inactivity.scheduledDate, DateTime(2026, 9, 11, 10, 0));
  });

  test('skips missed-tracking once that window has already passed, but keeps inactivity if still ahead', () {
    final streak = StreakStats(
      currentStreak: 0,
      bestStreak: 3,
      lastActivityDate: DateTime(2026, 8, 25),
      recordedToday: false,
    );
    final plans = planEngagementNotifications(
      streak: streak,
      now: DateTime(2026, 9, 1, 8),
      preferredHour: 10,
      preferredMinute: 0,
    );

    expect(plans.any((p) => p.kind == EngagementNotificationKind.missedTracking), isFalse);
    expect(plans.any((p) => p.kind == EngagementNotificationKind.inactivity), isTrue);
  });

  test('plans nothing further once both engagement windows have already passed', () {
    final streak = StreakStats(
      currentStreak: 0,
      bestStreak: 3,
      lastActivityDate: DateTime(2026, 8, 1),
      recordedToday: false,
    );
    final plans = planEngagementNotifications(
      streak: streak,
      now: DateTime(2026, 9, 4, 8),
      preferredHour: 10,
      preferredMinute: 0,
    );

    expect(plans, isEmpty);
  });
}
