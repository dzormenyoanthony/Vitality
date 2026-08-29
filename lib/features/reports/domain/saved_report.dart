import 'extracted_reading.dart';

/// The type of original document saved.
enum ReportDocumentType { image, pdf }

/// How the report entered Vitaly.
enum ReportSource { scan, import }

/// What kind of document this is, for filtering in the Saved Reports
/// "document locker" (`design_references/My document locker.png`).
/// [bpReport] is the default for anything scanned/imported through the
/// original "Scan BP Report" flow; the others let a user file other kinds
/// of health paperwork they keep in the same locker. This is purely an
/// organizational tag chosen by the user — Vitaly never infers or claims a
/// document's medical category automatically (PROJECT_SPEC.md §9, §14).
enum ReportCategory { bpReport, labResults, prescriptions, ecg, other }

/// Processing state of OCR extraction for a report (PROJECT_SPEC.md
/// "Scan BP Report" §4, §13-14). OCR never runs automatically into BP
/// History — this only tracks whether extraction was attempted/succeeded.
enum OcrStatus { notProcessed, processing, succeeded, failed }

/// A saved BP report: the preserved original document plus whatever the
/// user has extracted/confirmed from it (PROJECT_SPEC.md "Scan BP Report"
/// §8-9). The original document is never replaced by OCR output — this
/// model always keeps [localPagePaths] regardless of [ocrStatus].
final class SavedReport {
  const SavedReport({
    required this.id,
    this.remoteId,
    required this.title,
    required this.documentType,
    this.reportDate,
    required this.pageCount,
    required this.ocrStatus,
    this.extractedReadings = const [],
    this.confirmedReadings = const [],
    required this.source,
    required this.localPagePaths,
    this.storagePagePaths,
    this.category = ReportCategory.bpReport,
    this.provider,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String? remoteId;
  final String title;
  final ReportDocumentType documentType;
  final DateTime? reportDate;
  final int pageCount;
  final OcrStatus ocrStatus;

  /// User-chosen organizational category (default [ReportCategory.bpReport]
  /// for backward-compatible rows saved before this field existed).
  final ReportCategory category;

  /// Optional free-text source, e.g. a clinician or lab name ("Dr. Okafor",
  /// "Northside Lab") — purely informational, never validated or used in
  /// any calculation.
  final String? provider;

  /// Every candidate OCR detected, unconfirmed.
  final List<ExtractedReading> extractedReadings;

  /// The subset (possibly edited) the user has actually confirmed as
  /// accurate. Only entries here are eligible to be added to BP History,
  /// and only ever by explicit user action (PROJECT_SPEC.md §6).
  final List<ExtractedReading> confirmedReadings;
  final ReportSource source;

  /// Local file paths for each page image, in page order. Always present
  /// once the report is saved, even when [ocrStatus] is
  /// [OcrStatus.failed] (PROJECT_SPEC.md §8, §13).
  final List<String> localPagePaths;

  /// Firebase Storage paths mirroring [localPagePaths], once uploaded.
  final List<String>? storagePagePaths;
  final DateTime createdAt;
  final DateTime updatedAt;
}
