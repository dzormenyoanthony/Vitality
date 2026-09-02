import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../l10n/app_localizations.dart';
import '../data/blood_pressure_reading.dart';
import '../domain/trend_calculator.dart';
import '../domain/trend_summary_lines.dart';

/// App accent colors, mirrored from `AppColors` so the exported chart reads
/// the same as the on-screen Trends chart: teal systolic, coral diastolic,
/// purple pulse.
const _systolicColor = PdfColor.fromInt(0xFF0F7A72);
const _diastolicColor = PdfColor.fromInt(0xFFC2452C);
const _pulseColor = PdfColor.fromInt(0xFF5B4FCF);
const _gridColor = PdfColor.fromInt(0xFFE0E0E0);

/// Builds a shareable PDF containing exactly the same non-diagnostic
/// content already shown on-screen (PROJECT_SPEC.md §12, §28) — the
/// summary sentences from [trendSummaryLines], a plain line chart of the
/// readings in the period, and a plain list of those readings. No new
/// stats, no interpretation, and — matching the on-screen chart (§14) — no
/// reference bands, thresholds, or color-coded zones.
Future<Uint8List> buildTrendSummaryPdf(
  AppLocalizations l10n,
  TrendStats stats, {
  bool includePulse = true,
}) async {
  final doc = pw.Document();
  final lines = trendSummaryLines(l10n, stats, includePulse: includePulse);
  final readings = stats.readings;

  doc.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Header(level: 0, text: l10n.trendPdfTitle),
        pw.Text(l10n.trendPdfGenerated(_formatDate(DateTime.now()))),
        pw.SizedBox(height: 16),
        for (final line in lines) pw.Paragraph(text: line),
        if (readings.isNotEmpty) ...[
          pw.SizedBox(height: 8),
          pw.Header(level: 1, text: l10n.trendPdfChartHeader),
          if (readings.length < 2)
            pw.Text(
              l10n.trendPdfChartOmittedSingleReading,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            )
          else ...[
            _bpTrendChart(readings),
            pw.SizedBox(height: 6),
            _legend(l10n),
          ],
          if (includePulse) ..._pulseSection(l10n, readings),
        ],
        pw.SizedBox(height: 16),
        pw.Header(level: 1, text: l10n.trendPdfReadingsHeader),
        pw.TableHelper.fromTextArray(
          headers: [
            l10n.trendPdfColDate,
            l10n.trendPdfColTime,
            l10n.trendPdfColSystolic,
            l10n.trendPdfColDiastolic,
            if (includePulse) l10n.trendPdfColPulse,
          ],
          data: [
            for (final r in readings)
              [
                _formatDateOnly(r.timestamp),
                _formatTimeOnly(r.timestamp),
                '${r.systolic} mmHg',
                '${r.diastolic} mmHg',
                if (includePulse) r.pulse == null ? '-' : '${r.pulse} bpm',
              ],
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Text(
          l10n.trendPdfDisclaimer,
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
      ],
    ),
  );

  return doc.save();
}

/// Systolic + diastolic line chart over the period, in reading order —
/// the PDF twin of `_BpChart` on the Trends screen.
pw.Widget _bpTrendChart(List<BloodPressureReading> readings) {
  final systolic = <pw.PointChartValue>[];
  final diastolic = <pw.PointChartValue>[];
  for (var i = 0; i < readings.length; i++) {
    systolic.add(pw.PointChartValue(i.toDouble(), readings[i].systolic.toDouble()));
    diastolic.add(pw.PointChartValue(i.toDouble(), readings[i].diastolic.toDouble()));
  }

  final range = _AxisRange.fit([
    for (final r in readings) r.systolic.toDouble(),
    for (final r in readings) r.diastolic.toDouble(),
  ]);

  return pw.SizedBox(
    height: 190,
    child: pw.Chart(
      grid: pw.CartesianGrid(
        xAxis: pw.FixedAxis<double>(
          _xTicks(readings.length),
          format: (v) => _xLabel(readings, v.toInt()),
          divisions: false,
        ),
        yAxis: pw.FixedAxis<double>(
          range.ticks,
          divisions: true,
          divisionsColor: _gridColor,
          format: (v) => v.toInt().toString(),
        ),
      ),
      datasets: [
        pw.LineDataSet(
          data: systolic,
          color: _systolicColor,
          lineWidth: 2,
          drawPoints: false,
        ),
        pw.LineDataSet(
          data: diastolic,
          color: _diastolicColor,
          lineWidth: 2,
          drawPoints: false,
        ),
      ],
    ),
  );
}

/// The optional pulse chart + heading, when [includePulse] is on and at
/// least two readings in the period carry a pulse value.
List<pw.Widget> _pulseSection(
  AppLocalizations l10n,
  List<BloodPressureReading> readings,
) {
  final points = <pw.PointChartValue>[];
  for (var i = 0; i < readings.length; i++) {
    final pulse = readings[i].pulse;
    if (pulse != null) points.add(pw.PointChartValue(i.toDouble(), pulse.toDouble()));
  }
  if (points.length < 2) return const [];

  final range = _AxisRange.fit([for (final p in points) p.y]);

  return [
    pw.SizedBox(height: 12),
    pw.Header(level: 1, text: l10n.trendPdfPulseChartHeader),
    pw.SizedBox(
      height: 150,
      child: pw.Chart(
        grid: pw.CartesianGrid(
          xAxis: pw.FixedAxis<double>(
            _xTicks(readings.length),
            format: (v) => _xLabel(readings, v.toInt()),
            divisions: false,
          ),
          yAxis: pw.FixedAxis<double>(
            range.ticks,
            divisions: true,
            divisionsColor: _gridColor,
            format: (v) => v.toInt().toString(),
          ),
        ),
        datasets: [
          pw.LineDataSet(
            data: points,
            color: _pulseColor,
            lineWidth: 2,
            drawPoints: false,
          ),
        ],
      ),
    ),
  ];
}

pw.Widget _legend(AppLocalizations l10n) => pw.Row(
  children: [
    _legendSwatch(_systolicColor, l10n.trendsLegendSystolic),
    pw.SizedBox(width: 18),
    _legendSwatch(_diastolicColor, l10n.trendsLegendDiastolic),
  ],
);

pw.Widget _legendSwatch(PdfColor color, String label) => pw.Row(
  crossAxisAlignment: pw.CrossAxisAlignment.center,
  children: [
    pw.Container(width: 14, height: 3, color: color),
    pw.SizedBox(width: 5),
    pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
  ],
);

/// The x positions to label — first, middle, last reading — deduplicated
/// and ascending, as [pw.FixedAxis] requires.
List<double> _xTicks(int count) {
  final ticks = {0, (count - 1) ~/ 2, count - 1}.map((i) => i.toDouble()).toList()
    ..sort();
  return ticks;
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

String _formatDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String _formatDateOnly(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String _formatTimeOnly(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
