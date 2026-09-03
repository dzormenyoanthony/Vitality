import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/blood_pressure/data/blood_pressure_reading.dart';
import 'package:vitality/features/blood_pressure/domain/trend_calculator.dart';
import 'package:vitality/features/blood_pressure/presentation/trend_pdf_export.dart';
import 'package:vitality/features/reports/domain/saved_report.dart';
import 'package:vitality/l10n/app_localizations.dart';

import '../../../support/pump_app.dart';

BloodPressureReading _reading({
  required int id,
  required int systolic,
  required int diastolic,
  int? pulse,
  required DateTime timestamp,
  String? notes,
  List<MeasurementContext> contexts = const [],
  BodyPosition? bodyPosition,
  ReadingSource source = ReadingSource.manual,
  int? sourceReportId,
}) => BloodPressureReading(
  id: id,
  systolic: systolic,
  diastolic: diastolic,
  pulse: pulse,
  timestamp: timestamp,
  notes: notes,
  measurementContexts: contexts,
  bodyPosition: bodyPosition,
  source: source,
  sourceReportId: sourceReportId,
  createdAt: timestamp,
  updatedAt: timestamp,
);

SavedReport _report(int id, String title) => SavedReport(
  id: id,
  title: title,
  documentType: ReportDocumentType.pdf,
  pageCount: 1,
  ocrStatus: OcrStatus.notProcessed,
  source: ReportSource.import,
  localPagePaths: const ['/tmp/p1.pdf'],
  createdAt: DateTime(2026, 8, 1),
  updatedAt: DateTime(2026, 8, 1),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppLocalizations l10n;
  setUpAll(() async => l10n = await loadAppLocalizations());

  bool isPdf(List<int> bytes) => String.fromCharCodes(bytes.take(5)) == '%PDF-';

  // Page objects (`/Type /Page`) aren't inside the compressed content
  // streams, so they can be counted straight from the saved bytes.
  int pageCount(List<int> bytes) =>
      RegExp(r'/Type\s*/Page[^s]').allMatches(String.fromCharCodes(bytes)).length;

  test('produces non-empty PDF bytes starting with the PDF magic header', () async {
    final now = DateTime(2026, 8, 23);
    final stats = TrendCalculator.compute(
      [_reading(id: 1, systolic: 120, diastolic: 80, pulse: 70, timestamp: now)],
      TrendPeriod.sevenDays,
      now,
    );

    final bytes = await buildTrendSummaryPdf(l10n, stats);

    expect(bytes, isNotEmpty);
    expect(isPdf(bytes), isTrue);
  });

  test('does not throw for an empty reading list', () async {
    final now = DateTime(2026, 8, 23);
    final stats = TrendCalculator.compute([], TrendPeriod.sevenDays, now);

    final bytes = await buildTrendSummaryPdf(l10n, stats);

    expect(bytes, isNotEmpty);
    expect(isPdf(bytes), isTrue);
  });

  test('renders the systolic/diastolic and pulse charts for a multi-day '
      'period without throwing', () async {
    final now = DateTime(2026, 8, 23, 8);
    final readings = [
      for (var day = 0; day < 6; day++)
        _reading(
          id: day + 1,
          systolic: 118 + day * 3,
          diastolic: 76 + day,
          pulse: 68 + day,
          timestamp: now.subtract(Duration(days: 5 - day)),
        ),
    ];
    final stats = TrendCalculator.compute(readings, TrendPeriod.sevenDays, now);

    final bytes = await buildTrendSummaryPdf(l10n, stats);
    expect(isPdf(bytes), isTrue);

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
        _reading(
          id: i + 1,
          systolic: 120,
          diastolic: 80,
          pulse: 70,
          timestamp: now.subtract(Duration(days: 3 - i)),
        ),
    ];
    final stats = TrendCalculator.compute(readings, TrendPeriod.sevenDays, now);

    final bytes = await buildTrendSummaryPdf(l10n, stats);
    expect(bytes, isNotEmpty);
    expect(isPdf(bytes), isTrue);
  });

  test('omits the pulse chart when includePulse is false', () async {
    final now = DateTime(2026, 8, 23, 8);
    final readings = [
      for (var day = 0; day < 6; day++)
        _reading(
          id: day + 1,
          systolic: 118 + day * 3,
          diastolic: 76 + day,
          pulse: 68 + day,
          timestamp: now.subtract(Duration(days: 5 - day)),
        ),
    ];
    final stats = TrendCalculator.compute(readings, TrendPeriod.sevenDays, now);

    final withPulse = await buildTrendSummaryPdf(l10n, stats);
    final withoutPulse =
        await buildTrendSummaryPdf(l10n, stats, includePulse: false);

    expect(withoutPulse, isNotEmpty);
    expect(withoutPulse.length, lessThan(withPulse.length));
  });

  test('includes a patient block only when a name is supplied', () async {
    final now = DateTime(2026, 8, 23, 8);
    final readings = [
      for (var day = 0; day < 5; day++)
        _reading(
          id: day + 1,
          systolic: 120 + day,
          diastolic: 80,
          pulse: 70,
          timestamp: now.subtract(Duration(days: 4 - day)),
        ),
    ];
    final stats = TrendCalculator.compute(readings, TrendPeriod.thirtyDays, now);

    final withName = await buildTrendSummaryPdf(l10n, stats, patientName: 'Alex Doe');
    final withoutName = await buildTrendSummaryPdf(l10n, stats);
    final blankName = await buildTrendSummaryPdf(l10n, stats, patientName: '  ');

    expect(isPdf(withName), isTrue);
    expect(isPdf(withoutName), isTrue);
    // A blank/whitespace name is treated as no name: identical output.
    expect(blankName.length, withoutName.length);
  });

  test('handles readings with every optional field missing', () async {
    final now = DateTime(2026, 8, 23, 8);
    final readings = [
      for (var day = 0; day < 4; day++)
        _reading(
          id: day + 1,
          systolic: 122,
          diastolic: 78,
          timestamp: now.subtract(Duration(days: 3 - day)),
        ),
    ];
    final stats = TrendCalculator.compute(readings, TrendPeriod.sevenDays, now);

    final bytes = await buildTrendSummaryPdf(l10n, stats);
    expect(isPdf(bytes), isTrue);
  });

  test('renders notes, contexts, body position and an imported source '
      'in the readings table', () async {
    final now = DateTime(2026, 8, 23, 8);
    final readings = [
      _reading(
        id: 1,
        systolic: 128,
        diastolic: 84,
        pulse: 72,
        timestamp: now.subtract(const Duration(days: 2)),
        notes:
            'Felt a little stressed before the reading; retook it after '
            'sitting quietly for five minutes and the numbers were similar.',
        contexts: const [
          MeasurementContext.morning,
          MeasurementContext.beforeMedication,
        ],
        bodyPosition: BodyPosition.sitting,
      ),
      _reading(
        id: 2,
        systolic: 131,
        diastolic: 86,
        timestamp: now.subtract(const Duration(days: 1)),
        source: ReadingSource.importedReport,
        sourceReportId: 7,
      ),
    ];
    final stats = TrendCalculator.compute(readings, TrendPeriod.thirtyDays, now);

    final bytes = await buildTrendSummaryPdf(l10n, stats);
    expect(isPdf(bytes), isTrue);
  });

  test('adds a Supporting documents section when readings link to reports', () async {
    final now = DateTime(2026, 8, 23, 8);
    final readings = [
      _reading(
        id: 1,
        systolic: 126,
        diastolic: 82,
        timestamp: now.subtract(const Duration(days: 3)),
        source: ReadingSource.importedReport,
        sourceReportId: 7,
      ),
      _reading(
        id: 2,
        systolic: 129,
        diastolic: 83,
        timestamp: now.subtract(const Duration(days: 2)),
        source: ReadingSource.importedReport,
        sourceReportId: 7,
      ),
      _reading(
        id: 3,
        systolic: 124,
        diastolic: 80,
        timestamp: now.subtract(const Duration(days: 1)),
      ),
    ];
    final stats = TrendCalculator.compute(readings, TrendPeriod.thirtyDays, now);

    final withDocs = await buildTrendSummaryPdf(
      l10n,
      stats,
      reports: [_report(7, 'Cardiology clinic visit'), _report(9, 'Unrelated lab')],
    );
    expect(isPdf(withDocs), isTrue);

    // The section only appears when a reading references a report: passing
    // reports that nothing in the period links to must produce byte-identical
    // output to passing no reports at all.
    final noLinksStats = TrendCalculator.compute(
      [_reading(id: 1, systolic: 120, diastolic: 80, timestamp: now)],
      TrendPeriod.thirtyDays,
      now,
    );
    final unlinked = await buildTrendSummaryPdf(
      l10n,
      noLinksStats,
      reports: [_report(7, 'Cardiology clinic visit')],
    );
    final unlinkedNoReports = await buildTrendSummaryPdf(l10n, noLinksStats);
    expect(unlinked.length, unlinkedNoReports.length);
  });

  test('handles a report with a linked id that is no longer in the locker', () async {
    final now = DateTime(2026, 8, 23, 8);
    final stats = TrendCalculator.compute(
      [
        _reading(
          id: 1,
          systolic: 126,
          diastolic: 82,
          timestamp: now.subtract(const Duration(days: 1)),
          source: ReadingSource.importedReport,
          sourceReportId: 999,
        ),
      ],
      TrendPeriod.thirtyDays,
      now,
    );

    final bytes = await buildTrendSummaryPdf(l10n, stats, reports: const []);
    expect(isPdf(bytes), isTrue);
  });

  test('paginates a long reading history across multiple pages', () async {
    final now = DateTime(2026, 8, 23, 8);
    final readings = [
      for (var i = 0; i < 80; i++)
        _reading(
          id: i + 1,
          systolic: 118 + (i % 12),
          diastolic: 74 + (i % 8),
          pulse: 66 + (i % 10),
          timestamp: now.subtract(Duration(hours: (80 - i) * 8)),
          notes: i.isEven ? 'Routine morning check number $i' : null,
        ),
    ];
    final stats = TrendCalculator.compute(readings, TrendPeriod.ninetyDays, now);

    final bytes = await buildTrendSummaryPdf(l10n, stats);
    expect(isPdf(bytes), isTrue);
    // 80 rows can't fit one page, so the report runs onto more pages than a
    // 6-row one does.
    final small = await buildTrendSummaryPdf(
      l10n,
      TrendCalculator.compute(readings.take(6).toList(), TrendPeriod.ninetyDays, now),
    );
    expect(pageCount(bytes), greaterThan(pageCount(small)));
    expect(pageCount(bytes), greaterThanOrEqualTo(3));
  });

  test('handles the all-time period with no equivalent prior window', () async {
    final now = DateTime(2026, 8, 23, 8);
    final readings = [
      for (var i = 0; i < 10; i++)
        _reading(
          id: i + 1,
          systolic: 120 + i,
          diastolic: 80,
          pulse: 70,
          timestamp: now.subtract(Duration(days: 30 - i)),
        ),
    ];
    final stats = TrendCalculator.compute(readings, TrendPeriod.all, now);

    final bytes = await buildTrendSummaryPdf(l10n, stats);
    expect(isPdf(bytes), isTrue);
  });
}
