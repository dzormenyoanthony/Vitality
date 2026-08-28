import 'dart:typed_data';

/// Result of building a full data export (PROJECT_SPEC.md §28): the user's
/// BP readings as CSV plus every available scanned/saved report file,
/// packaged as one ZIP.
///
/// [missingReportFiles] lists any report file that exists in the database
/// but could not be read from local storage, identified by report title
/// (and page number, for a multi-page report). The export still succeeds
/// with whatever files were available — the caller is responsible for
/// telling the user about anything missing rather than silently dropping
/// it (PROJECT_SPEC.md "Scan BP Report" §13's OCR-failure handling follows
/// the same "never silently fail" principle).
final class DataExportResult {
  const DataExportResult({
    required this.zipBytes,
    required this.filename,
    required this.readingCount,
    required this.includedReportFileCount,
    required this.missingReportFiles,
  });

  final Uint8List zipBytes;
  final String filename;
  final int readingCount;
  final int includedReportFileCount;
  final List<String> missingReportFiles;

  bool get hasMissingFiles => missingReportFiles.isNotEmpty;
}
