import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../l10n/app_localizations.dart';
import '../domain/trend_calculator.dart';
import '../domain/trend_summary_lines.dart';

/// Builds a shareable PDF containing exactly the same non-diagnostic
/// content already shown on-screen (PROJECT_SPEC.md §12, §28) — the
/// summary sentences from [trendSummaryLines] plus a plain list of the
/// individual readings in the period. No new stats, no interpretation.
Future<Uint8List> buildTrendSummaryPdf(
  AppLocalizations l10n,
  TrendStats stats,
) async {
  final doc = pw.Document();
  final lines = trendSummaryLines(l10n, stats);

  doc.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Header(level: 0, text: l10n.trendPdfTitle),
        pw.Text(l10n.trendPdfGenerated(_formatDate(DateTime.now()))),
        pw.SizedBox(height: 16),
        for (final line in lines) pw.Paragraph(text: line),
        pw.SizedBox(height: 16),
        pw.Header(level: 1, text: l10n.trendPdfReadingsHeader),
        pw.TableHelper.fromTextArray(
          headers: [
            l10n.trendPdfColDate,
            l10n.trendPdfColTime,
            l10n.trendPdfColSystolic,
            l10n.trendPdfColDiastolic,
            l10n.trendPdfColPulse,
          ],
          data: [
            for (final r in stats.readings)
              [
                _formatDateOnly(r.timestamp),
                _formatTimeOnly(r.timestamp),
                '${r.systolic} mmHg',
                '${r.diastolic} mmHg',
                r.pulse == null ? '-' : '${r.pulse} bpm',
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

String _formatDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String _formatDateOnly(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String _formatTimeOnly(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
