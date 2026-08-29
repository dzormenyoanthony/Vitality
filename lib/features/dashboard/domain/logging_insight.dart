import '../../blood_pressure/data/blood_pressure_reading.dart';

/// Which time-of-day is underrepresented in the last 7 days.
enum LoggingInsightKind { morningGap, eveningGap }

/// A rule-based nudge derived purely from counts of the user's own logged
/// data — never a comment on what their numbers mean (PROJECT_SPEC.md
/// §12-14). Suggests a reminder time when one time-of-day is
/// underrepresented over the last 7 days.
///
/// The user-facing sentence is built by the presentation layer from
/// [kind], [morningDays], and [eveningDays] — this class deliberately
/// carries no reading values.
final class LoggingInsight {
  const LoggingInsight({
    required this.kind,
    required this.morningDays,
    required this.eveningDays,
    required this.suggestedHour,
    required this.suggestedMinute,
  });

  final LoggingInsightKind kind;
  final int morningDays;
  final int eveningDays;
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
      kind: LoggingInsightKind.morningGap,
      morningDays: morningDays,
      eveningDays: eveningDays,
      suggestedHour: 7,
      suggestedMinute: 30,
    );
  }
  if (eveningDays <= morningDays - 2) {
    return LoggingInsight(
      kind: LoggingInsightKind.eveningGap,
      morningDays: morningDays,
      eveningDays: eveningDays,
      suggestedHour: 20,
      suggestedMinute: 0,
    );
  }
  return null;
}
