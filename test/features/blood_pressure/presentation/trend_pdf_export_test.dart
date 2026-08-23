import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/blood_pressure/data/blood_pressure_reading.dart';
import 'package:vitality/features/blood_pressure/domain/trend_calculator.dart';
import 'package:vitality/features/blood_pressure/presentation/trend_pdf_export.dart';

void main() {
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

    final bytes = await buildTrendSummaryPdf(stats);

    expect(bytes, isNotEmpty);
    // PDF files start with "%PDF-".
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });

  test('does not throw for an empty reading list', () async {
    final now = DateTime(2026, 8, 23);
    final stats = TrendCalculator.compute([], TrendPeriod.sevenDays, now);

    final bytes = await buildTrendSummaryPdf(stats);

    expect(bytes, isNotEmpty);
  });
}
