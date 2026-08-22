/// Short weekday labels (Monday=1..Sunday=7, matching `DateTime.weekday`),
/// shared by the reminders list and form screens.
const weekdayShortLabels = {
  1: 'Mon',
  2: 'Tue',
  3: 'Wed',
  4: 'Thu',
  5: 'Fri',
  6: 'Sat',
  7: 'Sun',
};

/// Human-readable summary of a reminder's selected days, e.g. "Every day",
/// "Weekdays", or "Mon, Wed, Fri".
String daysSummary(Set<int> daysOfWeek) {
  if (daysOfWeek.length == 7) return 'Every day';
  if (daysOfWeek.length == 5 && !daysOfWeek.contains(6) && !daysOfWeek.contains(7)) {
    return 'Weekdays';
  }
  final sorted = daysOfWeek.toList()..sort();
  return sorted.map((d) => weekdayShortLabels[d]).join(', ');
}

String formatTimeOfDay(int hour, int minute) {
  final period = hour < 12 ? 'AM' : 'PM';
  final displayHour = hour % 12 == 0 ? 12 : hour % 12;
  return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
}
