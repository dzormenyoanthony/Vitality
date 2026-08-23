import '../../blood_pressure/data/blood_pressure_reading.dart';

/// A rule-based nudge derived purely from counts of the user's own logged
/// data — never a comment on what their numbers mean (PROJECT_SPEC.md
/// §12-14). Suggests a reminder time when one time-of-day is
/// underrepresented over the last 7 days.
final class LoggingInsight {
  const LoggingInsight({
    required this.message,
    required this.suggestedHour,
    required this.suggestedMinute,
  });

  final String message;
  final int suggestedHour;
  final int suggestedMinute;
}

/// Compares how many of the last 7 calendar days had a morning (before
/// noon) vs. an evening (noon or later) reading, and suggests a reminder
/// for whichever is meaningfully underrepresented (a gap of 2+ days).
/// `null` when there's not enough of a gap to say anything useful.
LoggingInsight? computeLoggingInsight(List<BloodPressureReading> readings, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  var morningDays = 0;
  var eveningDays = 0;

  for (var i = 0; i < 7; i++) {
    final day = today.subtract(Duration(days: i));
    final dayReadings = readings.where(
      (r) =>
          r.timestamp.year == day.year &&
          r.timestamp.month == day.month &&
          r.timestamp.day == day.day,
    );
    if (dayReadings.any((r) => r.timestamp.hour < 12)) morningDays++;
    if (dayReadings.any((r) => r.timestamp.hour >= 12)) eveningDays++;
  }

  if (morningDays + eveningDays == 0) return null;

  if (morningDays <= eveningDays - 2) {
    return LoggingInsight(
      message:
          'You logged $morningDays of the last 7 mornings and $eveningDays '
          'evenings. A morning reminder would even out the record.',
      suggestedHour: 7,
      suggestedMinute: 30,
    );
  }
  if (eveningDays <= morningDays - 2) {
    return LoggingInsight(
      message:
          'You logged $eveningDays of the last 7 evenings and $morningDays '
          'mornings. An evening reminder would even out the record.',
      suggestedHour: 20,
      suggestedMinute: 0,
    );
  }
  return null;
}
