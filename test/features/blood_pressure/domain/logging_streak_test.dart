import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/blood_pressure/data/blood_pressure_reading.dart';
import 'package:vitality/features/blood_pressure/domain/logging_streak.dart';

BloodPressureReading _reading(DateTime timestamp) => BloodPressureReading(
  id: 0,
  systolic: 120,
  diastolic: 80,
  timestamp: timestamp,
  createdAt: timestamp,
  updatedAt: timestamp,
);

void main() {
  test('returns 0 when there are no readings', () {
    expect(computeLoggingStreak([], DateTime(2026, 8, 23, 12)), 0);
  });

  test('returns 0 when the most recent reading is more than 24 hours old', () {
    final now = DateTime(2026, 8, 23, 12);
    final readings = [_reading(now.subtract(const Duration(hours: 25)))];
    expect(computeLoggingStreak(readings, now), 0);
  });

  test('counts a single reading within the last 24 hours as a 1-day streak', () {
    final now = DateTime(2026, 8, 23, 12);
    final readings = [_reading(now.subtract(const Duration(hours: 2)))];
    expect(computeLoggingStreak(readings, now), 1);
  });

  test(
    'two readings less than 24 hours apart count as one streak day, even across midnight',
    () {
      final now = DateTime(2026, 8, 23, 0, 5);
      final readings = [
        _reading(DateTime(2026, 8, 22, 23, 58)), // just before midnight
        _reading(now), // ~7 minutes later, just after midnight
      ];
      expect(computeLoggingStreak(readings, now), 1);
    },
  );

  test('readings at least 24 hours apart each extend the streak', () {
    final now = DateTime(2026, 8, 23, 8);
    final readings = [
      _reading(now),
      _reading(now.subtract(const Duration(hours: 24))),
      _reading(now.subtract(const Duration(hours: 48))),
    ];
    expect(computeLoggingStreak(readings, now), 3);
  });

  test('a gap of more than 24 hours between counted readings stops the streak', () {
    final now = DateTime(2026, 8, 23, 8);
    final readings = [
      _reading(now),
      _reading(now.subtract(const Duration(hours: 24))),
      // Gap: next reading is well over 24 hours before the last counted one.
      _reading(now.subtract(const Duration(hours: 84))),
    ];
    expect(computeLoggingStreak(readings, now), 2);
  });

  test('extra readings inside an already-counted window do not inflate the streak', () {
    final now = DateTime(2026, 8, 23, 8);
    final readings = [
      _reading(now),
      _reading(now.subtract(const Duration(hours: 1))),
      _reading(now.subtract(const Duration(hours: 24))),
      _reading(now.subtract(const Duration(hours: 25))),
    ];
    expect(computeLoggingStreak(readings, now), 2);
  });
}
