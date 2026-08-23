import '../data/blood_pressure_reading.dart';

/// Number of consecutive days, walking back from [today], that have at
/// least one reading. Zero if there's no reading today (the streak is
/// "still open" only while today has an entry — matches how a user would
/// read "9 day streak" on the day they've already logged).
///
/// Pure and testable in isolation, same shape as `TrendCalculator`.
int computeLoggingStreak(List<BloodPressureReading> readings, DateTime today) {
  final loggedDays = readings
      .map((r) => DateTime(r.timestamp.year, r.timestamp.month, r.timestamp.day))
      .toSet();

  var streak = 0;
  var day = DateTime(today.year, today.month, today.day);
  while (loggedDays.contains(day)) {
    streak++;
    day = day.subtract(const Duration(days: 1));
  }
  return streak;
}
