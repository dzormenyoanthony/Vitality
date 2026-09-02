import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:vitality/core/analytics/analytics_providers.dart';
import 'package:vitality/core/constants/app_routes.dart';
import 'package:vitality/features/blood_pressure/data/app_database.dart';
import 'package:vitality/features/blood_pressure/data/blood_pressure_providers.dart';
import 'package:vitality/features/reports/data/report_document_storage.dart';
import 'package:vitality/features/reports/data/report_providers.dart';
import 'package:vitality/features/reports/domain/saved_report.dart';
import 'package:vitality/features/reports/domain/text_recognition_service.dart';
import 'package:vitality/features/reports/presentation/review_extracted_screen.dart';

import '../../../support/fake_analytics_service.dart';
import '../../../support/pump_app.dart';

/// Headless walk of the full "Scan BP Report" persist path (Sections 4-8),
/// driven through the real router: canned OCR text -> real
/// [BpValueExtractor] -> real [ReviewExtractedScreen] -> Confirm -> real
/// [ConfirmReportController] -> real native Drift writes -> `context.go` to
/// Saved Reports.
///
/// Storage is stubbed: `flutter test`'s async model never delivers real
/// `dart:io` file-copy completions between `tester.pump()` calls, so the
/// real [ReportDocumentStorage.saveLocalPages] can only be exercised in
/// `integration_test/` (see project memory
/// `integration_test_ondevice_stall`). Everything else here runs for real,
/// and the extraction covers systolic, diastolic, pulse, and date.
class _CannedTextRecognitionService implements TextRecognitionService {
  _CannedTextRecognitionService(this._textByPath);

  final Map<String, String> _textByPath;
  int calls = 0;

  @override
  Future<String> recognizeText(String imagePath) async {
    calls++;
    return _textByPath[imagePath] ?? '';
  }

  @override
  Future<void> dispose() async {}
}

/// Pretends the picker's temp paths are already permanent; no I/O, no
/// upload — matching the pattern in `review_extracted_screen_test.dart`.
class _PassthroughReportDocumentStorage extends ReportDocumentStorage {
  @override
  Future<List<String>> saveLocalPages({
    required List<String> sourcePaths,
  }) async => sourcePaths;

  @override
  Future<List<String>?> uploadPages({
    required int reportId,
    required List<String> localPagePaths,
  }) async => null;
}

Future<void> _pumpUntil(
  WidgetTester tester,
  Finder finder, {
  int tries = 60,
}) async {
  for (var i = 0; i < tries; i++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) return;
  }
  expect(finder, findsWidgets);
}

void main() {
  testWidgets(
    'canned OCR text -> review (S/D/pulse/date) -> confirm -> Drift save + navigate',
    (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final analytics = FakeAnalyticsService();

      const sourcePath = '/picker/tmp/scan_src.jpg';
      final ocr = _CannedTextRecognitionService({
        sourcePath: '22 Aug 2026\n136 / 84 mmHg\nPulse 72 bpm',
      });

      final router = GoRouter(
        initialLocation: AppRoutes.reviewExtracted,
        routes: [
          GoRoute(
            path: AppRoutes.reviewExtracted,
            builder: (context, state) => ReviewExtractedScreen(
              args: ReviewExtractedArgs(
                rawPagePaths: [sourcePath],
                documentType: ReportDocumentType.image,
                source: ReportSource.scan,
              ),
            ),
          ),
          GoRoute(
            path: AppRoutes.savedReports,
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('SAVED REPORTS STUB'))),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            textRecognitionServiceProvider.overrideWithValue(ocr),
            reportDocumentStorageProvider
                .overrideWithValue(_PassthroughReportDocumentStorage()),
            analyticsServiceProvider.overrideWithValue(analytics),
          ],
          child: MaterialApp.router(
            localizationsDelegates: localizationWrappers,
            supportedLocales: testSupportedLocales,
            routerConfig: router,
          ),
        ),
      );

      // OCR runs in initState(); the parsed reading renders on the card.
      await _pumpUntil(tester, find.text('136/84 mmHg'));
      expect(ocr.calls, 1);
      expect(find.text('Needs review'), findsOneWidget);
      expect(find.textContaining('Pulse 72 bpm'), findsOneWidget);
      expect(find.textContaining('Aug 22, 2026'), findsOneWidget);

      await tester.tap(find.text('Confirm and save'));
      await _pumpUntil(tester, find.text('SAVED REPORTS STUB'));

      // Report row in real SQLite, carrying the confirmed reading.
      final reports = await db.select(db.savedReports).get();
      expect(reports, hasLength(1));
      expect(reports.single.localPagePaths, sourcePath);
      expect(reports.single.confirmedReadingsJson, contains('136'));

      // The reading is in BP History storage, tagged imported and linked
      // back to the report (i.e. it would show on the History screen).
      final readings = await db.select(db.readings).get();
      expect(readings, hasLength(1));
      expect(readings.single.systolic, 136);
      expect(readings.single.diastolic, 84);
      expect(readings.single.pulse, 72);
      expect(readings.single.timestamp, DateTime(2026, 8, 22));
      expect(readings.single.source, 'importedReport');
      expect(readings.single.sourceReportId, reports.single.id);

      expect(analytics.events, ['bp_reading_recorded:imported=true']);
    },
  );
}
