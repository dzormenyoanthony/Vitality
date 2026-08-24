import '../data/blood_pressure_reading.dart';

/// Number of consecutive ~24-hour windows, most recent first, that each
/// have at least one reading.
///
/// Windows are anchored to the most recent reading rather than the
/// calendar clock: a new window only starts once at least 24 real hours
/// have elapsed since the most recently *counted* reading — merely
/// crossing a calendar-day boundary (e.g. logging at 11:58pm and again
/// at 12:02am, four minutes later) does NOT advance the streak. If the
/// next-older reading falls more than 48 hours before the current
/// anchor, an entire window was skipped and the streak stops there,
/// mirroring the original "stops at the first gap" behavior. The streak
/// is 0 if the most recent reading is itself more than 24 hours before
/// [now] (the streak has gone stale).
///
/// Pure and testable in isolation, same shape as `TrendCalculator`.
int computeLoggingStreak(List<BloodPressureReading> readings, DateTime now) {
  if (readings.isEmpty) return 0;

  final sorted = readings.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  if (now.difference(sorted.first.timestamp) > const Duration(hours: 24)) {
    return 0;
  }

  const oneDay = Duration(hours: 24);
  const twoDays = Duration(hours: 48);

  var streak = 1;
  var anchor = sorted.first.timestamp;
  for (var i = 1; i < sorted.length; i++) {
    final gap = anchor.difference(sorted[i].timestamp);
    if (gap < oneDay) {
      // Same window as the anchor — doesn't extend the streak on its own.
      continue;
    } else if (gap < twoDays) {
      streak++;
      anchor = sorted[i].timestamp;
    } else {
      // A full window was skipped entirely — the streak stops here.
      break;
    }
  }
  return streak;
}
