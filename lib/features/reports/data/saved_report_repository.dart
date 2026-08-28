import '../domain/extracted_reading.dart';
import '../domain/saved_report.dart';

/// Abstraction over local saved-report storage (Drift), mirroring
/// `BloodPressureRepository`'s shape so Phase 2 sync/testing patterns stay
/// consistent (PROJECT_SPEC.md "Scan BP Report" §9-10).
abstract interface class SavedReportRepository {
  /// All of the signed-in user's reports, newest first.
  Stream<List<SavedReport>> watchAll();

  Stream<SavedReport?> watchById(int id);

  /// A one-shot snapshot of every report, for a single non-reactive read
  /// (e.g. account deletion) rather than opening a new live subscription.
  Future<List<SavedReport>> getAll();

  Future<int> add({
    required String title,
    required ReportDocumentType documentType,
    DateTime? reportDate,
    required int pageCount,
    required OcrStatus ocrStatus,
    List<ExtractedReading> extractedReadings = const [],
    List<ExtractedReading> confirmedReadings = const [],
    required ReportSource source,
    required List<String> localPagePaths,
  });

  Future<void> updateOcrResult({
    required int id,
    required OcrStatus ocrStatus,
    List<ExtractedReading> extractedReadings = const [],
  });

  Future<void> updateConfirmedReadings({
    required int id,
    required List<ExtractedReading> confirmedReadings,
  });

  Future<void> rename({required int id, required String title});

  /// Records the Firebase Storage paths for [id]'s pages once uploaded
  /// (`ReportDocumentStorage`'s best-effort background push).
  Future<void> updateStoragePagePaths({
    required int id,
    required List<String> storagePagePaths,
  });

  Future<void> delete(int id);

  /// Deletes every report. Used when deleting the account (PROJECT_SPEC.md
  /// §25), same as `BloodPressureRepository.deleteAll`.
  Future<void> deleteAll();
}
