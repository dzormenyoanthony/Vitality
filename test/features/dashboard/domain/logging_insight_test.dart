import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/blood_pressure/data/blood_pressure_reading.dart';
import 'package:vitality/features/dashboard/domain/logging_insight.dart';

BloodPressureReading _reading(DateTime timestamp) => BloodPressureReading(
  id: 0,
  systolic: 120,
  diastolic: 80,
  timestamp: timestamp,
  createdAt: timestamp,
  updatedAt: timestamp,
);

void main() {
  final now = DateTime(2026, 8, 23, 12);

  test('returns null when there are no readings in the last 7 days', () {
    expect(computeLoggingInsight([], now), isNull);
  });

  test('suggests a morning reminder when evenings dominate', () {
    final readings = [
      for (var i = 0; i < 5; i++) _reading(now.subtract(Duration(days: i)).add(const Duration(hours: 8))),
    ];
    final insight = computeLoggingInsight(readings, now);
    expect(insight, isNotNull);
    expect(insight!.suggestedHour, 7);
    expect(insight.message, contains('evenings'));
  });

  test('suggests an evening reminder when mornings dominate', () {
    // now.hour is 12, so "add 8 hours" from midnight-of-day puts these at
    // 08:00 each day -> morning.
    final readings = [
      for (var i = 0; i < 5; i++)
        _reading(DateTime(now.year, now.month, now.day - i, 8)),
    ];
    final insight = computeLoggingInsight(readings, now);
    expect(insight, isNotNull);
    expect(insight!.suggestedHour, 20);
    expect(insight.message, contains('mornings'));
  });

  test('returns null when morning/evening logging is balanced', () {
    final readings = [
      _reading(DateTime(now.year, now.month, now.day, 8)),
      _reading(DateTime(now.year, now.month, now.day, 20)),
    ];
    expect(computeLoggingInsight(readings, now), isNull);
  });

  test('never mentions the reading values themselves', () {
    final readings = [
      for (var i = 0; i < 5; i++) _reading(DateTime(now.year, now.month, now.day - i, 20)),
    ];
    final insight = computeLoggingInsight(readings, now);
    expect(insight, isNotNull);
    expect(insight!.message, isNot(contains('mmHg')));
    expect(insight.message, isNot(contains('120')));
  });
}
