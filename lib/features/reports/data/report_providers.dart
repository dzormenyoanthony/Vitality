import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../blood_pressure/data/blood_pressure_providers.dart';
import '../domain/document_scanner_service.dart';
import '../domain/saved_report.dart';
import '../domain/text_recognition_service.dart';
import 'drift_saved_report_repository.dart';
import 'report_document_storage.dart';
import 'saved_report_repository.dart';

final documentScannerServiceProvider = Provider<DocumentScannerService>((ref) {
  return MlkitDocumentScannerService();
});

/// Tests override this with a fake [TextRecognitionService] — the real
/// implementation talks to a native ML Kit method channel unavailable in
/// widget tests.
final textRecognitionServiceProvider = Provider<TextRecognitionService>((ref) {
  final service = MlkitTextRecognitionService();
  ref.onDispose(service.dispose);
  return service;
});

/// Local-only by default (no Firebase Storage upload) — overridden in
/// `main.dart` with a real `FirebaseStorage` instance once Firebase is
/// initialized, same pattern as `bloodPressureRepositoryProvider`.
final reportDocumentStorageProvider = Provider<ReportDocumentStorage>((ref) {
  return ReportDocumentStorage();
});

/// Concrete [SavedReportRepository] used by the running app. Tests override
/// this with a repository backed by an in-memory Drift database instead of
/// the on-disk one.
final savedReportRepositoryProvider = Provider<SavedReportRepository>((ref) {
  return DriftSavedReportRepository(ref.watch(appDatabaseProvider));
});

final savedReportsStreamProvider = StreamProvider<List<SavedReport>>((ref) {
  return ref.watch(savedReportRepositoryProvider).watchAll();
});

final savedReportStreamProvider = StreamProvider.family<SavedReport?, int>(
  (ref, id) => ref.watch(savedReportRepositoryProvider).watchById(id),
);
