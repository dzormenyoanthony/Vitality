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
    expect(computeLoggingStreak([], DateTime(2026, 8, 23)), 0);
  });

  test('returns 0 when today has no reading, even if yesterday does', () {
    final readings = [_reading(DateTime(2026, 8, 22, 9))];
    expect(computeLoggingStreak(readings, DateTime(2026, 8, 23)), 0);
  });

  test('counts consecutive days with a reading, walking back from today', () {
    final readings = [
      _reading(DateTime(2026, 8, 23, 8)),
      _reading(DateTime(2026, 8, 22, 20)),
      _reading(DateTime(2026, 8, 21, 8)),
    ];
    expect(computeLoggingStreak(readings, DateTime(2026, 8, 23)), 3);
  });

  test('stops at the first gap', () {
    final readings = [
      _reading(DateTime(2026, 8, 23, 8)),
      _reading(DateTime(2026, 8, 22, 8)),
      // Gap on Aug 21.
      _reading(DateTime(2026, 8, 20, 8)),
    ];
    expect(computeLoggingStreak(readings, DateTime(2026, 8, 23)), 2);
  });

  test('multiple readings on the same day count as one day', () {
    final readings = [
      _reading(DateTime(2026, 8, 23, 8)),
      _reading(DateTime(2026, 8, 23, 20)),
    ];
    expect(computeLoggingStreak(readings, DateTime(2026, 8, 23)), 1);
  });
}
