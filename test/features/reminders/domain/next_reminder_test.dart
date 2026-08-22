import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/reminders/data/reminder.dart';
import 'package:vitality/features/reminders/domain/next_reminder.dart';

Reminder _reminder({
  int id = 1,
  String label = 'Reminder',
  required int hour,
  required int minute,
  required Set<int> daysOfWeek,
  bool enabled = true,
}) {
  final now = DateTime(2026, 1, 1);
  return Reminder(
    id: id,
    label: label,
    hour: hour,
    minute: minute,
    daysOfWeek: daysOfWeek,
    enabled: enabled,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('NextReminderCalculator.compute', () {
    test('returns null when there are no reminders', () {
      expect(NextReminderCalculator.compute([], DateTime(2026, 1, 5, 9)), isNull);
    });

    test('ignores disabled reminders', () {
      final reminder = _reminder(hour: 10, minute: 0, daysOfWeek: {1}, enabled: false);
      // 2026-01-05 is a Monday.
      final result = NextReminderCalculator.compute([reminder], DateTime(2026, 1, 5, 9));
      expect(result, isNull);
    });

    test('picks later today when the time has not yet passed', () {
      final reminder = _reminder(hour: 18, minute: 0, daysOfWeek: {1});
      // Monday 9am, reminder is Monday 6pm -> same day.
      final now = DateTime(2026, 1, 5, 9);
      final result = NextReminderCalculator.compute([reminder], now);

      expect(result!.when, DateTime(2026, 1, 5, 18, 0));
    });

    test('rolls over to next week when today\'s time has already passed', () {
      final reminder = _reminder(hour: 8, minute: 0, daysOfWeek: {1});
      // Monday 9am, reminder is Monday 8am -> already passed, so next Monday.
      final now = DateTime(2026, 1, 5, 9);
      final result = NextReminderCalculator.compute([reminder], now);

      expect(result!.when, DateTime(2026, 1, 12, 8, 0));
    });

    test('picks the nearest of several selected weekdays', () {
      // Monday=1, Wednesday=3, Friday=5.
      final reminder = _reminder(hour: 8, minute: 0, daysOfWeek: {1, 3, 5});
      // Tuesday 9am -> nearest is Wednesday 8am.
      final now = DateTime(2026, 1, 6, 9);
      final result = NextReminderCalculator.compute([reminder], now);

      expect(result!.when, DateTime(2026, 1, 7, 8, 0));
    });

    test('picks the soonest occurrence across multiple reminders', () {
      final soon = _reminder(id: 1, label: 'Soon', hour: 20, minute: 0, daysOfWeek: {1});
      final later = _reminder(id: 2, label: 'Later', hour: 8, minute: 0, daysOfWeek: {3});
      final now = DateTime(2026, 1, 5, 9); // Monday 9am.

      final result = NextReminderCalculator.compute([later, soon], now);

      expect(result!.reminder.label, 'Soon');
      expect(result.when, DateTime(2026, 1, 5, 20, 0));
    });
  });
}
