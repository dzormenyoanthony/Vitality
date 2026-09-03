import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../l10n/app_localizations.dart';
import '../../reports/domain/saved_report.dart';
import '../data/blood_pressure_reading.dart';
import '../domain/trend_calculator.dart';
import '../domain/trend_summary_lines.dart' show categoryMovementLine;
import 'measurement_context_label.dart';

/// Series colours, mirrored from `AppColors` so the exported charts read
/// the same as the on-screen Trends chart: teal systolic, coral diastolic,
/// purple pulse.
const _systolicColor = PdfColor.fromInt(0xFF0F7A72);
const _diastolicColor = PdfColor.fromInt(0xFFC2452C);
const _pulseColor = PdfColor.fromInt(0xFF5B4FCF);

/// Report chrome — one restrained brand colour, everything else neutral.
const _brand = PdfColor.fromInt(0xFF0F7A72);
const _ink = PdfColor.fromInt(0xFF1F1F1F);
const _muted = PdfColor.fromInt(0xFF6B6B6B);
const _hairline = PdfColor.fromInt(0xFFD8D8D8);
const _gridColor = PdfColor.fromInt(0xFFE0E0E0);
const _cardFill = PdfColor.fromInt(0xFFF3F6F5);
const _calloutFill = PdfColor.fromInt(0xFFF7F3EC);

const _pagePadding = pw.EdgeInsets.fromLTRB(42, 40, 42, 46);

/// Builds a shareable "Blood Pressure Trend Summary" — a polished
/// record-keeping report of what the user recorded or imported in Vitaly
/// during the selected period (PROJECT_SPEC.md §12, §28). It presents the
/// same values already shown on-screen; it introduces no new statistics
/// and no interpretation of the readings.
///
/// [patientName] is the user's Vitaly profile name, shown in the patient
/// block when present; nothing else personal is requested for the report.
/// [reports] is the Document Locker, used only to name the documents that
/// readings in this report were imported from.
Future<Uint8List> buildTrendSummaryPdf(
  AppLocalizations l10n,
  TrendStats stats, {
  bool includePulse = true,
  String? patientName,
  List<SavedReport> reports = const [],
}) async {
  final generatedAt = DateTime.now();
  final reportId = _reportId(generatedAt);
  final readings = stats.readings; // oldest first
  final periodStart = _periodStart(stats, generatedAt);
  final periodEnd = readings.isNotEmpty ? readings.last.timestamp : generatedAt;

  final doc = pw.Document(
    title: l10n.trendReportTitle,
    author: l10n.appTitle,
    subject: l10n.trendReportSubtitle,
  );

  final baseTheme = pw.ThemeData.base().copyWith(
    defaultTextStyle: const pw.TextStyle(fontSize: 10, color: _ink, lineSpacing: 2),
  );

  doc.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: _pagePadding,
        theme: baseTheme,
      ),
      header: (context) =>
          context.pageNumber == 1 ? pw.SizedBox() : _runningHeader(l10n),
      footer: (context) => _footer(l10n, context, reportId, generatedAt),
      build: (context) => [
        // 1 — professional header
        _titleBlock(l10n, generatedAt, stats, periodStart, periodEnd),
        // 2 — patient information (only when a profile name exists)
        if (_hasName(patientName))
          _section(l10n.trendReportPatientHeader, [
            _keyValue(l10n.trendReportPatientName, patientName!.trim()),
          ]),
        // 3 — summary card grid
        _section(l10n.trendReportSummaryHeader, [
          _summaryGrid(l10n, stats, includePulse: includePulse),
          pw.SizedBox(height: 10),
          pw.Text(
            l10n.trendReportContextLine,
            style: const pw.TextStyle(fontSize: 9, color: _muted),
          ),
        ]),
        // 4 — factual tracking activity
        _section(
          l10n.trendReportActivityHeader,
          _activityContent(l10n, stats, generatedAt),
        ),
        // 5 & 6 — blood pressure and pulse trend charts
        ..._trendCharts(l10n, readings, includePulse: includePulse),
        // 7 — full readings table. The header and table are separate
        // top-level items (not wrapped in a Column) so MultiPage can split
        // the table across pages and repeat its header row.
        _sectionHeader(l10n.trendReportReadingsHeader),
        pw.SizedBox(height: 10),
        if (readings.isEmpty)
          pw.Text(l10n.trendReportNoReadings,
              style: const pw.TextStyle(fontSize: 9, color: _muted))
        else
          _readingsTable(l10n, readings, includePulse: includePulse),
        pw.SizedBox(height: 18),
        // 8 — supporting documents (only when a reading links to one)
        ..._supportingDocuments(l10n, readings, reports),
        // 9 — note for the healthcare professional
        _section(l10n.trendReportForClinicianHeader, [
          pw.Text(l10n.trendReportForClinicianBody,
              style: const pw.TextStyle(fontSize: 9.5)),
        ]),
        // 10 — privacy reminder
        _callout(l10n.trendReportPrivacyNotice),
        // 12 — medical-safety disclaimer (footer/metadata is section 11)
        pw.SizedBox(height: 12),
        pw.Text(
          l10n.trendReportDisclaimer,
          style: const pw.TextStyle(fontSize: 8.5, color: _muted, lineSpacing: 2),
        ),
      ],
    ),
  );

  return doc.save();
}

// ---------------------------------------------------------------------------
// Title / header / footer
// ---------------------------------------------------------------------------

pw.Widget _titleBlock(
  AppLocalizations l10n,
  DateTime generatedAt,
  TrendStats stats,
  DateTime periodStart,
  DateTime periodEnd,
) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        l10n.splashWordmark,
        style: pw.TextStyle(
          fontSize: 11,
          color: _brand,
          fontWeight: pw.FontWeight.bold,
          letterSpacing: 3,
        ),
      ),
      pw.SizedBox(height: 8),
      pw.Text(
        l10n.trendReportTitle,
        style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: _ink),
      ),
      pw.SizedBox(height: 2),
      pw.Text(
        l10n.trendReportSubtitle,
        style: const pw.TextStyle(fontSize: 11, color: _muted),
      ),
      pw.SizedBox(height: 10),
      pw.Text(
        l10n.trendReportGeneratedLine(_formatDateTime(generatedAt)),
        style: const pw.TextStyle(fontSize: 9.5, color: _muted),
      ),
      pw.Text(
        l10n.trendReportPeriodLine(
          _periodLabel(l10n, stats.period),
          _formatDate(periodStart),
          _formatDate(periodEnd),
        ),
        style: const pw.TextStyle(fontSize: 9.5, color: _muted),
      ),
      pw.SizedBox(height: 12),
      pw.Divider(color: _brand, thickness: 1.4, height: 1.4),
      pw.SizedBox(height: 16),
    ],
  );
}

pw.Widget _runningHeader(AppLocalizations l10n) => pw.Column(
  children: [
    pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          l10n.trendReportTitle,
          style: const pw.TextStyle(fontSize: 8, color: _muted),
        ),
        pw.Text(
          l10n.splashWordmark,
          style: pw.TextStyle(
            fontSize: 8,
            color: _brand,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ],
    ),
    pw.SizedBox(height: 4),
    pw.Divider(color: _hairline, thickness: 0.6, height: 0.6),
    pw.SizedBox(height: 12),
  ],
);

pw.Widget _footer(
  AppLocalizations l10n,
  pw.Context context,
  String reportId,
  DateTime generatedAt,
) {
  return pw.Column(
    children: [
      pw.Divider(color: _hairline, thickness: 0.6, height: 0.6),
      pw.SizedBox(height: 4),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            l10n.appTitle,
            style: pw.TextStyle(fontSize: 7.5, color: _muted, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            l10n.trendReportFooterReportId(reportId),
            style: const pw.TextStyle(fontSize: 7.5, color: _muted),
          ),
          pw.Text(
            l10n.trendReportFooterPage(context.pageNumber, context.pagesCount),
            style: const pw.TextStyle(fontSize: 7.5, color: _muted),
          ),
        ],
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Sections
// ---------------------------------------------------------------------------

pw.Widget _sectionHeader(String title) => pw.Column(
  crossAxisAlignment: pw.CrossAxisAlignment.start,
  children: [
    pw.Text(
      title,
      style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: _brand),
    ),
    pw.SizedBox(height: 4),
    pw.Divider(color: _hairline, thickness: 0.8, height: 0.8),
  ],
);

pw.Widget _section(String title, List<pw.Widget> children) => pw.Container(
  margin: const pw.EdgeInsets.only(bottom: 18),
  child: pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _sectionHeader(title),
      pw.SizedBox(height: 10),
      ...children,
    ],
  ),
);

pw.Widget _keyValue(String label, String value) => pw.Padding(
  padding: const pw.EdgeInsets.only(bottom: 3),
  child: pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.SizedBox(
        width: 130,
        child: pw.Text(label, style: const pw.TextStyle(fontSize: 9.5, color: _muted)),
      ),
      pw.Expanded(
        child: pw.Text(value, style: const pw.TextStyle(fontSize: 9.5)),
      ),
    ],
  ),
);

pw.Widget _callout(String text) => pw.Container(
  width: double.infinity,
  padding: const pw.EdgeInsets.all(10),
  decoration: const pw.BoxDecoration(
    color: _calloutFill,
    borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
  ),
  child: pw.Text(text, style: const pw.TextStyle(fontSize: 9, color: _ink)),
);

// ---------------------------------------------------------------------------
// Summary grid
// ---------------------------------------------------------------------------

pw.Widget _summaryGrid(
  AppLocalizations l10n,
  TrendStats stats, {
  required bool includePulse,
}) {
  final cards = <pw.Widget>[
    _statCard(l10n.trendReportStatAvgSystolic, _roundOrDash(stats.avgSystolic), l10n.unitMmhg),
    _statCard(l10n.trendReportStatAvgDiastolic, _roundOrDash(stats.avgDiastolic), l10n.unitMmhg),
    if (includePulse)
      _statCard(l10n.trendReportStatAvgPulse, _roundOrDash(stats.avgPulse), l10n.unitBpm),
    _statCard(l10n.trendReportStatReadings, stats.readingCount.toString(), null),
  ];

  final rows = <pw.Widget>[];
  for (var i = 0; i < cards.length; i += 2) {
    rows.add(
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(child: cards[i]),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: i + 1 < cards.length ? cards[i + 1] : pw.SizedBox(),
          ),
        ],
      ),
    );
    if (i + 2 < cards.length) rows.add(pw.SizedBox(height: 10));
  }
  return pw.Column(children: rows);
}

pw.Widget _statCard(String label, String value, String? unit) => pw.Container(
  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  decoration: const pw.BoxDecoration(
    color: _cardFill,
    borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
  ),
  child: pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(label.toUpperCase(), style: const pw.TextStyle(fontSize: 7.5, color: _muted, letterSpacing: 0.5)),
      pw.SizedBox(height: 4),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text(value, style: pw.TextStyle(fontSize: 19, fontWeight: pw.FontWeight.bold, color: _ink)),
          if (unit != null) ...[
            pw.SizedBox(width: 4),
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 2),
              child: pw.Text(unit, style: const pw.TextStyle(fontSize: 8, color: _muted)),
            ),
          ],
        ],
      ),
    ],
  ),
);

// ---------------------------------------------------------------------------
// Tracking activity
// ---------------------------------------------------------------------------

List<pw.Widget> _activityContent(
  AppLocalizations l10n,
  TrendStats stats,
  DateTime generatedAt,
) {
  final lines = <String>[
    l10n.trendReportActivityInPeriod(stats.readingCount),
    if (stats.previousPeriodReadingCount != null) ...[
      l10n.trendReportActivityPreviousPeriod(stats.previousPeriodReadingCount!),
      _frequencyComparison(l10n, stats.readingCount, stats.previousPeriodReadingCount!),
    ],
    ?categoryMovementLine(l10n, stats),
    if (stats.readings.isNotEmpty)
      l10n.trendReportActivityMostRecent(
        '${stats.readings.last.systolic}/${stats.readings.last.diastolic}',
        _formatDateTime(stats.readings.last.timestamp),
      ),
  ];

  return [for (final line in lines) _bulletLine(line)];
}

/// A drawn dot + text row. Not [pw.Bullet]: its default "•" glyph isn't in
/// the built-in Helvetica, so it would render blank.
pw.Widget _bulletLine(String text, {double fontSize = 9.5}) => pw.Padding(
  padding: const pw.EdgeInsets.only(bottom: 4),
  child: pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Container(
        margin: const pw.EdgeInsets.only(top: 3.5, right: 6),
        width: 2.6,
        height: 2.6,
        decoration: const pw.BoxDecoration(color: _brand, shape: pw.BoxShape.circle),
      ),
      pw.Expanded(
        child: pw.Text(text, style: pw.TextStyle(fontSize: fontSize)),
      ),
    ],
  ),
);

String _frequencyComparison(AppLocalizations l10n, int current, int previous) {
  if (current == previous) return l10n.trendFrequencySame;
  return current < previous ? l10n.trendFrequencyFewer : l10n.trendFrequencyMore;
}

// ---------------------------------------------------------------------------
// Charts
// ---------------------------------------------------------------------------

List<pw.Widget> _trendCharts(
  AppLocalizations l10n,
  List<BloodPressureReading> readings, {
  required bool includePulse,
}) {
  if (readings.isEmpty) {
    return [
      _section(l10n.trendReportBpChartHeader, [
        pw.Text(l10n.trendReportNoReadings, style: const pw.TextStyle(fontSize: 9, color: _muted)),
      ]),
    ];
  }
  if (readings.length < 2) {
    return [
      _section(l10n.trendReportBpChartHeader, [
        pw.Text(l10n.trendReportChartNeedsTwo, style: const pw.TextStyle(fontSize: 9, color: _muted)),
      ]),
    ];
  }

  final pulsePoints = _pulsePoints(readings);
  return [
    _section(l10n.trendReportBpChartHeader, [
      pw.Text(l10n.trendReportChartCaptionBp, style: const pw.TextStyle(fontSize: 8.5, color: _muted)),
      pw.SizedBox(height: 8),
      _lineChart(
        readings: readings,
        series: [
          (_seriesFor(readings, (r) => r.systolic.toDouble()), _systolicColor),
          (_seriesFor(readings, (r) => r.diastolic.toDouble()), _diastolicColor),
        ],
        height: 200,
      ),
      pw.SizedBox(height: 8),
      _legend([
        (_systolicColor, l10n.trendReportLegendSystolic),
        (_diastolicColor, l10n.trendReportLegendDiastolic),
      ]),
    ]),
    if (includePulse && pulsePoints.length >= 2)
      _section(l10n.trendReportPulseChartHeader, [
        pw.Text(l10n.trendReportChartCaptionPulse, style: const pw.TextStyle(fontSize: 8.5, color: _muted)),
        pw.SizedBox(height: 8),
        _lineChart(
          readings: readings,
          series: [(pulsePoints, _pulseColor)],
          height: 160,
        ),
        pw.SizedBox(height: 8),
        _legend([(_pulseColor, l10n.trendReportLegendPulse)]),
      ]),
  ];
}

List<pw.PointChartValue> _seriesFor(
  List<BloodPressureReading> readings,
  double Function(BloodPressureReading) value,
) => [
  for (var i = 0; i < readings.length; i++)
    pw.PointChartValue(i.toDouble(), value(readings[i])),
];

/// Pulse points keep their real x index so they line up under the same
/// date labels as the BP chart even when some readings have no pulse.
List<pw.PointChartValue> _pulsePoints(List<BloodPressureReading> readings) => [
  for (var i = 0; i < readings.length; i++)
    if (readings[i].pulse != null)
      pw.PointChartValue(i.toDouble(), readings[i].pulse!.toDouble()),
];

pw.Widget _lineChart({
  required List<BloodPressureReading> readings,
  required List<(List<pw.PointChartValue>, PdfColor)> series,
  required double height,
}) {
  final range = _AxisRange.fit([
    for (final (points, _) in series)
      for (final p in points) p.y,
  ]);

  return pw.SizedBox(
    height: height,
    child: pw.Chart(
      grid: pw.CartesianGrid(
        xAxis: pw.FixedAxis<double>(
          _xTicks(readings.length),
          format: (v) => _xLabel(readings, v.toInt()),
          divisions: false,
          textStyle: const pw.TextStyle(fontSize: 7, color: _muted),
          // Inset the plot start so the first date label clears the y-axis
          // number column instead of overprinting it.
          marginStart: 26,
        ),
        yAxis: pw.FixedAxis<double>(
          range.ticks,
          divisions: true,
          divisionsColor: _gridColor,
          divisionsWidth: 0.5,
          format: (v) => v.toInt().toString(),
          textStyle: const pw.TextStyle(fontSize: 7, color: _muted),
        ),
      ),
      datasets: [
        for (final (points, color) in series)
          pw.LineDataSet(
            data: points,
            color: color,
            lineWidth: 1.6,
            drawPoints: true,
            pointColor: color,
            pointSize: 2,
            isCurved: false,
          ),
      ],
    ),
  );
}

pw.Widget _legend(List<(PdfColor, String)> entries) => pw.Wrap(
  spacing: 18,
  runSpacing: 4,
  children: [
    for (final (color, label) in entries)
      pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Container(width: 14, height: 3, color: color),
          pw.SizedBox(width: 5),
          pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: _muted)),
        ],
      ),
  ],
);

/// Up to five evenly spaced reading indices to label on the x-axis,
/// deduplicated and ascending as [pw.FixedAxis] requires.
List<double> _xTicks(int count) {
  if (count <= 1) return [0];
  final wanted = count < 5 ? count : 5;
  final ticks = <int>{};
  for (var i = 0; i < wanted; i++) {
    ticks.add((i * (count - 1) / (wanted - 1)).round());
  }
  final list = ticks.map((i) => i.toDouble()).toList()..sort();
  return list;
}

String _xLabel(List<BloodPressureReading> readings, int index) {
  if (index < 0 || index >= readings.length) return '';
  final ts = readings[index].timestamp;
  return '${ts.day}/${ts.month}';
}

/// A padded, 10-rounded y-axis range fitted to the data — the same shape
/// the on-screen chart uses so out-of-range points never clip.
class _AxisRange {
  const _AxisRange(this.ticks);

  final List<double> ticks;

  factory _AxisRange.fit(List<double> values) {
    if (values.isEmpty) return const _AxisRange([0, 40, 80, 120, 160]);
    var dataMin = values.first;
    var dataMax = values.first;
    for (final v in values) {
      if (v < dataMin) dataMin = v;
      if (v > dataMax) dataMax = v;
    }
    final minY = ((dataMin - 10) / 10).floor() * 10.0;
    var maxY = ((dataMax + 10) / 10).ceil() * 10.0;
    if (maxY <= minY) maxY = minY + 40;
    var interval = ((maxY - minY) / 4 / 10).ceil() * 10.0;
    if (interval < 10) interval = 10;

    final ticks = <double>[];
    for (var v = minY; v <= maxY + 0.5; v += interval) {
      ticks.add(v);
    }
    return _AxisRange(ticks);
  }
}

// ---------------------------------------------------------------------------
// Readings table
// ---------------------------------------------------------------------------

pw.Widget _readingsTable(
  AppLocalizations l10n,
  List<BloodPressureReading> readings, {
  required bool includePulse,
}) {
  final headers = <String>[
    l10n.trendPdfColDate,
    l10n.trendPdfColTime,
    l10n.trendPdfColSystolic,
    l10n.trendPdfColDiastolic,
    if (includePulse) l10n.trendPdfColPulse,
    l10n.trendReportColSource,
    l10n.trendReportColContext,
    l10n.trendReportColNotes,
    l10n.trendReportColReport,
  ];

  final data = <List<String>>[
    for (final r in readings)
      [
        _formatDate(r.timestamp),
        _formatTime(r.timestamp),
        r.systolic.toString(),
        r.diastolic.toString(),
        if (includePulse) r.pulse?.toString() ?? _dash,
        r.source == ReadingSource.importedReport
            ? l10n.trendReportSourceImported
            : l10n.trendReportSourceManual,
        _contextLabels(l10n, r),
        (r.notes == null || r.notes!.trim().isEmpty) ? _dash : r.notes!.trim(),
        r.sourceReportId?.toString() ?? _dash,
      ],
  ];

  final numericCols = includePulse ? {2, 3, 4} : {2, 3};

  return pw.TableHelper.fromTextArray(
    headers: headers,
    data: data,
    headerStyle: pw.TextStyle(
      fontSize: 7,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.white,
    ),
    headerDecoration: const pw.BoxDecoration(color: _brand),
    headerHeight: 22,
    cellStyle: const pw.TextStyle(fontSize: 7.5, color: _ink),
    cellHeight: 15,
    cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
    oddRowDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF7F9F9)),
    border: pw.TableBorder.symmetric(
      inside: const pw.BorderSide(color: _hairline, width: 0.4),
    ),
    columnWidths: {
      0: const pw.FlexColumnWidth(1.7),
      1: const pw.FlexColumnWidth(1.0),
      2: const pw.FlexColumnWidth(1.3),
      3: const pw.FlexColumnWidth(1.3),
      if (includePulse) 4: const pw.FlexColumnWidth(1.0),
      (includePulse ? 5 : 4): const pw.FlexColumnWidth(1.3),
      (includePulse ? 6 : 5): const pw.FlexColumnWidth(2.2),
      (includePulse ? 7 : 6): const pw.FlexColumnWidth(3.4),
      (includePulse ? 8 : 7): const pw.FlexColumnWidth(1.1),
    },
    cellAlignments: {
      for (final c in numericCols) c: pw.Alignment.centerRight,
    },
    headerAlignments: {
      for (final c in numericCols) c: pw.Alignment.centerRight,
    },
  );
}

String _contextLabels(AppLocalizations l10n, BloodPressureReading r) {
  final parts = <String>[
    for (final c in r.measurementContexts) c.label(l10n),
    if (r.bodyPosition != null) r.bodyPosition!.label(l10n),
  ];
  return parts.isEmpty ? _dash : parts.join(', ');
}

// ---------------------------------------------------------------------------
// Supporting documents
// ---------------------------------------------------------------------------

List<pw.Widget> _supportingDocuments(
  AppLocalizations l10n,
  List<BloodPressureReading> readings,
  List<SavedReport> reports,
) {
  final counts = <int, int>{};
  for (final r in readings) {
    final id = r.sourceReportId;
    if (id != null) counts[id] = (counts[id] ?? 0) + 1;
  }
  if (counts.isEmpty) return const [];

  final byId = {for (final report in reports) report.id: report};
  final entries = counts.keys.toList()..sort();

  return [
    pw.SizedBox(height: 20),
    _sectionHeader(l10n.trendReportDocsHeader),
    pw.SizedBox(height: 8),
    pw.Text(l10n.trendReportDocsIntro, style: const pw.TextStyle(fontSize: 9, color: _muted)),
    pw.SizedBox(height: 8),
    for (final id in entries)
      _bulletLine(
        l10n.trendReportDocsLine(
          byId[id]?.title ?? l10n.trendReportDocsUnknownTitle,
          id.toString(),
          counts[id]!,
        ),
        fontSize: 9,
      ),
  ];
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// Plain hyphen — the built-in Helvetica has no glyph for an en/em dash.
const _dash = '-';

bool _hasName(String? name) => name != null && name.trim().isNotEmpty;

String _roundOrDash(double? value) => value == null ? _dash : value.round().toString();

DateTime _periodStart(TrendStats stats, DateTime generatedAt) {
  final days = stats.period.days;
  if (days != null) return generatedAt.subtract(Duration(days: days));
  return stats.readings.isNotEmpty ? stats.readings.first.timestamp : generatedAt;
}

String _periodLabel(AppLocalizations l10n, TrendPeriod period) => period == TrendPeriod.all
    ? l10n.trendSummaryPeriodAll
    : l10n.trendsPeriodName(period.name);

String _reportId(DateTime dt) =>
    'VITALY-${dt.year}${_two(dt.month)}${_two(dt.day)}-${_two(dt.hour)}${_two(dt.minute)}${_two(dt.second)}';

String _two(int n) => n.toString().padLeft(2, '0');

String _formatDate(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';

String _formatTime(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';

String _formatDateTime(DateTime d) => '${_formatDate(d)} ${_formatTime(d)}';
