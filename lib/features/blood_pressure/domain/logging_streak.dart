import '../data/blood_pressure_reading.dart';

/// Calendar-day blood-pressure logging streak stats (PROJECT_SPEC.md §10,
/// §17, §23).
///
/// Built purely from the *calendar days* (local timezone) that have at
/// least one reading — deliberately blind to how many readings were taken
/// on a given day, so recording twice in one day never inflates the streak
/// and the feature never rewards excessive measurement.
final class StreakStats {
  const StreakStats({
    required this.currentStreak,
    required this.bestStreak,
    required this.lastActivityDate,
    required this.recordedToday,
  });

  static const empty = StreakStats(
    currentStreak: 0,
    bestStreak: 0,
    lastActivityDate: null,
    recordedToday: false,
  );

  /// Consecutive qualifying days up to and including today, or up to
  /// yesterday if today has no reading yet (the streak stays "current"
  /// until a full day is missed). Zero once a day has actually been missed.
  final int currentStreak;

  /// The longest run of consecutive qualifying days across all history,
  /// including the current run.
  final int bestStreak;

  /// The most recent calendar day (local, date-only) with a reading, or
  /// `null` if there are no readings at all.
  final DateTime? lastActivityDate;

  /// Whether today already has at least one qualifying reading.
  final bool recordedToday;

  /// The streak is active but hasn't been secured for today yet — one more
  /// day without a reading and it lapses. Never true when there is no
  /// active streak, so this never nudges a user who isn't already keeping
  /// one.
  bool get isAtRisk => currentStreak > 0 && !recordedToday;
}

DateTime _dateOnly(DateTime t) => DateTime(t.year, t.month, t.day);

/// Computes [StreakStats] from every recorded reading, anchored to [now]
/// (local time). Pure and testable in isolation, same shape as
/// `TrendCalculator`/`NextReminderCalculator`.
StreakStats computeStreakStats(List<BloodPressureReading> readings, DateTime now) {
  if (readings.isEmpty) return StreakStats.empty;

  final days = readings.map((r) => _dateOnly(r.timestamp)).toSet();
  final today = _dateOnly(now);
  final recordedToday = days.contains(today);

  var currentStreak = 0;
  var cursor = recordedToday ? today : today.subtract(const Duration(days: 1));
  while (days.contains(cursor)) {
    currentStreak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }

  final sortedDays = days.toList()..sort();
  var bestStreak = 0;
  var run = 0;
  DateTime? previous;
  for (final day in sortedDays) {
    run = (previous != null && day.difference(previous).inDays == 1) ? run + 1 : 1;
    if (run > bestStreak) bestStreak = run;
    previous = day;
  }
  if (currentStreak > bestStreak) bestStreak = currentStreak;

  return StreakStats(
    currentStreak: currentStreak,
    bestStreak: bestStreak,
    lastActivityDate: sortedDays.last,
    recordedToday: recordedToday,
  );
}
