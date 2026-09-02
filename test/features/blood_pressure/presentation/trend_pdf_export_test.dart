import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/blood_pressure/data/blood_pressure_reading.dart';
import 'package:vitality/features/blood_pressure/domain/trend_calculator.dart';
import 'package:vitality/features/blood_pressure/presentation/trend_pdf_export.dart';
import 'package:vitality/l10n/app_localizations.dart';

import '../../../support/pump_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppLocalizations l10n;
  setUpAll(() async => l10n = await loadAppLocalizations());
  test('produces non-empty PDF bytes starting with the PDF magic header', () async {
    final now = DateTime(2026, 8, 23);
    final reading = BloodPressureReading(
      id: 1,
      systolic: 120,
      diastolic: 80,
      pulse: 70,
      timestamp: now,
      createdAt: now,
      updatedAt: now,
    );
    final stats = TrendCalculator.compute([reading], TrendPeriod.sevenDays, now);

    final bytes = await buildTrendSummaryPdf(l10n, stats);

    expect(bytes, isNotEmpty);
    // PDF files start with "%PDF-".
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });

  test('does not throw for an empty reading list', () async {
    final now = DateTime(2026, 8, 23);
    final stats = TrendCalculator.compute([], TrendPeriod.sevenDays, now);

    final bytes = await buildTrendSummaryPdf(l10n, stats);

    expect(bytes, isNotEmpty);
  });

  test('renders the systolic/diastolic and pulse charts for a multi-day '
      'period without throwing', () async {
    final now = DateTime(2026, 8, 23, 8);
    final readings = [
      for (var day = 0; day < 6; day++)
        BloodPressureReading(
          id: day + 1,
          systolic: 118 + day * 3,
          diastolic: 76 + day,
          pulse: 68 + day,
          timestamp: now.subtract(Duration(days: 5 - day)),
          createdAt: now,
          updatedAt: now,
        ),
    ];
    final stats = TrendCalculator.compute(readings, TrendPeriod.sevenDays, now);

    final bytes = await buildTrendSummaryPdf(l10n, stats);

    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    // A charted 6-reading PDF is materially larger than the single-reading
    // one (which skips the chart), so the vector chart really landed.
    final singleStats = TrendCalculator.compute(
      [readings.first],
      TrendPeriod.sevenDays,
      now,
    );
    final singleBytes = await buildTrendSummaryPdf(l10n, singleStats);
    expect(bytes.length, greaterThan(singleBytes.length));
  });

  test('handles a period where every reading is identical '
      '(degenerate y-axis range)', () async {
    final now = DateTime(2026, 8, 23, 8);
    final readings = [
      for (var i = 0; i < 4; i++)
        BloodPressureReading(
          id: i + 1,
          systolic: 120,
          diastolic: 80,
          pulse: 70,
          timestamp: now.subtract(Duration(days: 3 - i)),
          createdAt: now,
          updatedAt: now,
        ),
    ];
    final stats = TrendCalculator.compute(readings, TrendPeriod.sevenDays, now);

    final bytes = await buildTrendSummaryPdf(l10n, stats);

    expect(bytes, isNotEmpty);
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });

  test('omits the pulse chart when includePulse is false', () async {
    final now = DateTime(2026, 8, 23, 8);
    final readings = [
      for (var day = 0; day < 6; day++)
        BloodPressureReading(
          id: day + 1,
          systolic: 118 + day * 3,
          diastolic: 76 + day,
          pulse: 68 + day,
          timestamp: now.subtract(Duration(days: 5 - day)),
          createdAt: now,
          updatedAt: now,
        ),
    ];
    final stats = TrendCalculator.compute(readings, TrendPeriod.sevenDays, now);

    final withPulse = await buildTrendSummaryPdf(l10n, stats);
    final withoutPulse =
        await buildTrendSummaryPdf(l10n, stats, includePulse: false);

    expect(withoutPulse, isNotEmpty);
    expect(withoutPulse.length, lessThan(withPulse.length));
  });
}
