/// The window of readings to include in a data export
/// (`design_references/Export Data screen.png`). Extends PROJECT_SPEC.md
/// §28, which otherwise exports the user's entire history.
enum ExportDateRange { last30Days, last90Days, thisYear, allTime }

extension ExportDateRangeWindow on ExportDateRange {
  /// The earliest timestamp to include, or `null` for no lower bound.
  DateTime? startFrom(DateTime now) => switch (this) {
    ExportDateRange.last30Days => now.subtract(const Duration(days: 30)),
    ExportDateRange.last90Days => now.subtract(const Duration(days: 90)),
    ExportDateRange.thisYear => DateTime(now.year),
    ExportDateRange.allTime => null,
  };
}

/// Which artifact the export produces.
///
/// - [pdfSummary] reuses the Trends one-page PDF (§11 / §28's "Trends PDF
///   summary").
/// - [csvSpreadsheet] is the readings CSV on its own.
/// - [fullArchive] is §28's ZIP: the CSV plus every attached scanned
///   document.
enum ExportFormat { pdfSummary, csvSpreadsheet, fullArchive }

/// Everything the export screen collects before building a file.
final class ExportOptions {
  const ExportOptions({
    this.dateRange = ExportDateRange.last30Days,
    this.format = ExportFormat.pdfSummary,
    this.includeNotesAndTags = true,
    this.includeAttachedDocuments = true,
    this.includePulse = false,
  });

  final ExportDateRange dateRange;
  final ExportFormat format;

  /// Off drops the Notes and Measurement Context columns from the CSV
  /// (§28 already lists both as "if available"). No effect on the PDF.
  final bool includeNotesAndTags;

  /// Off omits the `scanned_reports/` folder from the [ExportFormat.fullArchive]
  /// ZIP. No effect on the other formats.
  final bool includeAttachedDocuments;

  /// Off drops the Pulse column from the CSV and the pulse line/column
  /// from the PDF (§28 lists Pulse as "if available").
  final bool includePulse;

  ExportOptions copyWith({
    ExportDateRange? dateRange,
    ExportFormat? format,
    bool? includeNotesAndTags,
    bool? includeAttachedDocuments,
    bool? includePulse,
  }) => ExportOptions(
    dateRange: dateRange ?? this.dateRange,
    format: format ?? this.format,
    includeNotesAndTags: includeNotesAndTags ?? this.includeNotesAndTags,
    includeAttachedDocuments:
        includeAttachedDocuments ?? this.includeAttachedDocuments,
    includePulse: includePulse ?? this.includePulse,
  );
}
