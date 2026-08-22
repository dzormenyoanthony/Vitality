import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/blood_pressure/data/blood_pressure_reading.dart';
import 'package:vitality/features/blood_pressure/domain/trend_calculator.dart';

BloodPressureReading _reading({
  required int id,
  required int systolic,
  required int diastolic,
  int? pulse,
  required DateTime timestamp,
}) {
  return BloodPressureReading(
    id: id,
    systolic: systolic,
    diastolic: diastolic,
    pulse: pulse,
    timestamp: timestamp,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

void main() {
  final now = DateTime(2026, 1, 15, 12);

  group('TrendCalculator.compute', () {
    test('returns zeroed stats for an empty reading list', () {
      final stats = TrendCalculator.compute([], TrendPeriod.sevenDays, now);

      expect(stats.readingCount, 0);
      expect(stats.avgSystolic, isNull);
      expect(stats.avgDiastolic, isNull);
      expect(stats.avgPulse, isNull);
    });

    test('excludes readings outside the selected period', () {
      final readings = [
        _reading(id: 1, systolic: 120, diastolic: 80, timestamp: now.subtract(const Duration(days: 3))),
        _reading(id: 2, systolic: 130, diastolic: 85, timestamp: now.subtract(const Duration(days: 10))),
      ];

      final stats = TrendCalculator.compute(readings, TrendPeriod.sevenDays, now);

      expect(stats.readingCount, 1);
      expect(stats.avgSystolic, 120);
    });

    test('includes a reading exactly at the period boundary', () {
      final readings = [
        _reading(id: 1, systolic: 120, diastolic: 80, timestamp: now.subtract(const Duration(days: 7))),
      ];

      final stats = TrendCalculator.compute(readings, TrendPeriod.sevenDays, now);

      expect(stats.readingCount, 1);
    });

    test('computes correct averages across multiple readings', () {
      final readings = [
        _reading(id: 1, systolic: 120, diastolic: 80, timestamp: now.subtract(const Duration(days: 1))),
        _reading(id: 2, systolic: 130, diastolic: 90, timestamp: now.subtract(const Duration(days: 2))),
      ];

      final stats = TrendCalculator.compute(readings, TrendPeriod.sevenDays, now);

      expect(stats.avgSystolic, 125);
      expect(stats.avgDiastolic, 85);
    });

    test('averages pulse only across readings that have one', () {
      final readings = [
        _reading(id: 1, systolic: 120, diastolic: 80, pulse: 70, timestamp: now.subtract(const Duration(days: 1))),
        _reading(id: 2, systolic: 130, diastolic: 90, timestamp: now.subtract(const Duration(days: 2))),
      ];

      final stats = TrendCalculator.compute(readings, TrendPeriod.sevenDays, now);

      expect(stats.avgPulse, 70);
      expect(stats.hasPulseData, isTrue);
    });

    test('reports no pulse data when no reading in the period has one', () {
      final readings = [
        _reading(id: 1, systolic: 120, diastolic: 80, timestamp: now.subtract(const Duration(days: 1))),
      ];

      final stats = TrendCalculator.compute(readings, TrendPeriod.sevenDays, now);

      expect(stats.hasPulseData, isFalse);
    });

    test('orders readings within the period oldest first', () {
      final readings = [
        _reading(id: 1, systolic: 130, diastolic: 85, timestamp: now.subtract(const Duration(days: 1))),
        _reading(id: 2, systolic: 120, diastolic: 80, timestamp: now.subtract(const Duration(days: 3))),
      ];

      final stats = TrendCalculator.compute(readings, TrendPeriod.sevenDays, now);

      expect(stats.readings.map((r) => r.id).toList(), [2, 1]);
    });

    test('compares against the equivalent prior window', () {
      final readings = [
        // In the current 7-day window.
        _reading(id: 1, systolic: 120, diastolic: 80, timestamp: now.subtract(const Duration(days: 1))),
        // In the prior 7-day window (days 8-14 ago).
        _reading(id: 2, systolic: 120, diastolic: 80, timestamp: now.subtract(const Duration(days: 9))),
        _reading(id: 3, systolic: 120, diastolic: 80, timestamp: now.subtract(const Duration(days: 10))),
      ];

      final stats = TrendCalculator.compute(readings, TrendPeriod.sevenDays, now);

      expect(stats.readingCount, 1);
      expect(stats.previousPeriodReadingCount, 2);
    });

    test('has no prior-window comparison for the "all" period', () {
      final readings = [
        _reading(id: 1, systolic: 120, diastolic: 80, timestamp: now.subtract(const Duration(days: 1))),
      ];

      final stats = TrendCalculator.compute(readings, TrendPeriod.all, now);

      expect(stats.previousPeriodReadingCount, isNull);
      expect(stats.readingCount, 1);
    });
  });
}
