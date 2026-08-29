import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/analytics/analytics_providers.dart';
import '../../blood_pressure/data/blood_pressure_providers.dart';
import '../../blood_pressure/data/blood_pressure_reading.dart';
import '../data/report_providers.dart';
import '../domain/extracted_reading.dart';
import '../domain/saved_report.dart';

/// Saves a reviewed report: writes the original pages to permanent local
/// storage, records the [SavedReport] (always — even with no confirmed
/// readings, PROJECT_SPEC.md "Scan BP Report" §8), adds whichever confirmed
/// readings the user selected to BP History, and best-effort uploads the
/// pages to Firebase Storage in the background.
///
/// Mirrors the shape of `RecordBpController`/`SettingsController`: an
/// [AsyncNotifier] tracking only this action's loading/error state.
class ConfirmReportController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// The id of the report saved by the most recent successful
  /// [confirmAndSave] call — read this after the call completes
  /// successfully (check `state.hasError` first, same pattern as
  /// `RecordBpController`) to navigate to it.
  int? lastSavedReportId;

  Future<void> confirmAndSave({
    required String title,
    required ReportDocumentType documentType,
    required List<String> rawPagePaths,
    required OcrStatus ocrStatus,
    required List<ExtractedReading> extractedReadings,
    required List<ExtractedReading> confirmedReadings,
    required Set<int> selectedForHistoryIds,
    required ReportSource source,
    ReportCategory category = ReportCategory.bpReport,
    String? provider,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final storage = ref.read(reportDocumentStorageProvider);
      final localPagePaths = await storage.saveLocalPages(sourcePaths: rawPagePaths);

      final reportRepository = ref.read(savedReportRepositoryProvider);
      final id = await reportRepository.add(
        title: title,
        documentType: documentType,
        reportDate: confirmedReadings.isEmpty ? null : confirmedReadings.first.timestamp,
        pageCount: localPagePaths.length,
        ocrStatus: ocrStatus,
        extractedReadings: extractedReadings,
        confirmedReadings: confirmedReadings,
        source: source,
        localPagePaths: localPagePaths,
        category: category,
        provider: provider,
      );

      final bloodPressureRepository = ref.read(bloodPressureRepositoryProvider);
      final analytics = ref.read(analyticsServiceProvider);
      for (final reading in confirmedReadings) {
        if (!selectedForHistoryIds.contains(reading.id)) continue;
        await bloodPressureRepository.addReading(
          systolic: reading.systolic,
          diastolic: reading.diastolic,
          pulse: reading.pulse,
          timestamp: reading.timestamp ?? DateTime.now(),
          source: ReadingSource.importedReport,
          sourceReportId: id,
        );
        // PROJECT_SPEC.md §26 — reading recorded; no values are sent.
        analytics.logBpReadingRecorded(imported: true);
      }

      // Best-effort: never block confirming on the network. `SyncCoordinator`
      // only reconciles report metadata, not file bytes, so a failed upload
      // here isn't retried automatically — the local copy saved above
      // remains the source of truth regardless.
      unawaited(
        storage.uploadPages(reportId: id, localPagePaths: localPagePaths).then((uploaded) {
          if (uploaded != null) {
            reportRepository.updateStoragePagePaths(id: id, storagePagePaths: uploaded);
          }
        }),
      );

      lastSavedReportId = id;
    });
  }
}

final confirmReportControllerProvider = AsyncNotifierProvider<ConfirmReportController, void>(
  ConfirmReportController.new,
);
