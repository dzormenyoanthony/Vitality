import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/blood_pressure/data/blood_pressure_reading.dart';
import 'package:vitality/features/blood_pressure/domain/trend_calculator.dart';
import 'package:vitality/features/blood_pressure/domain/trend_summary_lines.dart';
import 'package:vitality/l10n/app_localizations.dart';

import '../../../support/pump_app.dart';

BloodPressureReading _reading({
  required int systolic,
  required int diastolic,
  required DateTime timestamp,
}) {
  return BloodPressureReading(
    id: 0,
    systolic: systolic,
    diastolic: diastolic,
    timestamp: timestamp,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppLocalizations l10n;
  setUpAll(() async => l10n = await loadAppLocalizations());
  final now = DateTime(2026, 2, 1);

  group('categoryMovementLine', () {
    test('is null when there is no prior-period average', () {
      final stats = TrendCalculator.compute(
        [_reading(systolic: 136, diastolic: 84, timestamp: now)],
        TrendPeriod.sevenDays,
        now,
      );
      expect(categoryMovementLine(l10n, stats), isNull);
    });

    test('is null when the category has not changed', () {
      final readings = [
        _reading(systolic: 110, diastolic: 70, timestamp: now),
        _reading(systolic: 112, diastolic: 72, timestamp: now.subtract(const Duration(days: 10))),
      ];
      final stats = TrendCalculator.compute(readings, TrendPeriod.sevenDays, now);
      expect(categoryMovementLine(l10n, stats), isNull);
    });

    test('describes a category change using category names, never a diagnosis', () {
      final readings = [
        _reading(systolic: 120, diastolic: 79, timestamp: now), // elevated
        _reading(systolic: 132, diastolic: 84, timestamp: now.subtract(const Duration(days: 10))), // higher
      ];
      final stats = TrendCalculator.compute(readings, TrendPeriod.sevenDays, now);

      final line = categoryMovementLine(l10n, stats);
      expect(line, isNotNull);
      expect(line, contains('higher category'));
      expect(line, contains('elevated category'));
      expect(line!.toLowerCase(), isNot(contains('hypertension')));
      expect(line.toLowerCase(), isNot(contains('improved')));
      expect(line.toLowerCase(), isNot(contains('worse')));
    });
  });

  group('trendSummaryLines', () {
    test('includes the category-movement line only when present', () {
      final readings = [
        _reading(systolic: 120, diastolic: 79, timestamp: now),
        _reading(systolic: 132, diastolic: 84, timestamp: now.subtract(const Duration(days: 10))),
      ];
      final stats = TrendCalculator.compute(readings, TrendPeriod.sevenDays, now);

      final lines = trendSummaryLines(l10n, stats);

      expect(lines.any((l) => l.contains('moved from')), isTrue);
    });

    test('includes the average status line with the non-diagnostic category label', () {
      final stats = TrendCalculator.compute(
        [_reading(systolic: 136, diastolic: 84, timestamp: now)],
        TrendPeriod.sevenDays,
        now,
      );

      final lines = trendSummaryLines(l10n, stats);

      expect(lines.any((l) => l.contains('Average status') && l.contains('Higher than the usual range')), isTrue);
    });

    test('never claims a diagnosis or treatment outcome', () {
      final stats = TrendCalculator.compute(
        [_reading(systolic: 150, diastolic: 95, timestamp: now)],
        TrendPeriod.sevenDays,
        now,
      );

      final combined = trendSummaryLines(l10n, stats).join(' ').toLowerCase();
      for (final forbidden in [
        'hypertension',
        'you have',
        'diagnos',
        'you need medication',
        'you are safe',
      ]) {
        expect(combined, isNot(contains(forbidden)));
      }
    });
  });
}
