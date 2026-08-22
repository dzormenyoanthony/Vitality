import '../data/reminder.dart';

/// The nearest upcoming occurrence of a reminder, for Dashboard display.
final class NextReminderOccurrence {
  const NextReminderOccurrence({required this.reminder, required this.when});

  final Reminder reminder;
  final DateTime when;
}

/// Computes the soonest upcoming occurrence across all enabled reminders
/// (PROJECT_SPEC.md §10's "next reminder" dashboard slot). Pure and
/// timezone-independent (uses local `DateTime` only) — this is for display
/// only, not actual OS scheduling (see `NotificationScheduler` for that).
abstract final class NextReminderCalculator {
  static NextReminderOccurrence? compute(List<Reminder> reminders, DateTime now) {
    NextReminderOccurrence? soonest;

    for (final reminder in reminders) {
      if (!reminder.enabled || reminder.daysOfWeek.isEmpty) continue;
      for (final weekday in reminder.daysOfWeek) {
        final when = _nextOccurrence(now, weekday, reminder.hour, reminder.minute);
        if (soonest == null || when.isBefore(soonest.when)) {
          soonest = NextReminderOccurrence(reminder: reminder, when: when);
        }
      }
    }
    return soonest;
  }

  static DateTime _nextOccurrence(DateTime now, int weekday, int hour, int minute) {
    var candidate = DateTime(now.year, now.month, now.day, hour, minute);
    while (candidate.weekday != weekday || !candidate.isAfter(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }
}
