/// Fixed local-notification ids for the engagement-notification categories
/// (PROJECT_SPEC.md §23): streak-at-risk, missed-tracking, inactivity, and
/// the weekly summary.
///
/// Deliberately large and far apart from reminder notification ids, which
/// are `reminderId * 10 + weekday` (small Drift autoincrement ids) — so the
/// two id spaces can never collide.
abstract final class EngagementNotificationIds {
  static const streakAtRisk = 900001;
  static const missedTracking = 900002;
  static const inactivity = 900003;
  static const weeklySummary = 900004;
}
