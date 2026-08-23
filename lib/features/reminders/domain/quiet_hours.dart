import '../data/reminder.dart';

/// Whether [reminder]'s fixed fire time falls inside its own quiet-hours
/// window. The window may wrap past midnight (e.g. 22:00-07:00).
///
/// Pure and testable in isolation, same shape as
/// `NextReminderCalculator`/`TrendCalculator`.
bool isWithinQuietHours(Reminder reminder) {
  final start = reminder.quietHoursStart;
  final end = reminder.quietHoursEnd;
  if (start == null || end == null) return false;

  final fireMinutes = reminder.hour * 60 + reminder.minute;
  final startMinutes = start.$1 * 60 + start.$2;
  final endMinutes = end.$1 * 60 + end.$2;

  if (startMinutes <= endMinutes) {
    return fireMinutes >= startMinutes && fireMinutes < endMinutes;
  }
  // Window wraps past midnight (e.g. 22:00-07:00).
  return fireMinutes >= startMinutes || fireMinutes < endMinutes;
}
