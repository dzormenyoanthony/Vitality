import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:vitality/core/constants/app_routes.dart';
import 'package:vitality/features/blood_pressure/data/app_database.dart';
import 'package:vitality/features/blood_pressure/data/blood_pressure_providers.dart';
import 'package:vitality/features/blood_pressure/presentation/history_screen.dart';
import 'package:vitality/features/reports/data/report_providers.dart';
import 'package:vitality/features/reports/domain/saved_report.dart';
import 'package:vitality/features/reports/domain/text_recognition_service.dart';
import 'package:vitality/features/reports/presentation/review_extracted_screen.dart';
import 'package:vitality/l10n/app_localizations.dart';

/// PROJECT_SPEC.md §37 / "Scan BP Report" §4-8: end-to-end coverage of the
/// scan-report pipeline *on a real device* — real Flutter engine, real
/// native SQLite (Drift), real `path_provider` file IO through the actual
/// [ReportDocumentStorage], real navigation.
///
/// Only the ML Kit text recognizer is stubbed (with canned OCR text): the
/// `google_mlkit_text_recognition` plugin can't be fed a deterministic
/// image, and the document-scanner UI needs a live camera capture. Every
/// other step from "OCR produced this text" onwards runs for real.
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

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'canned OCR text flows through review -> confirm -> real Drift save -> History',
    (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      // A real file on disk so the real ReportDocumentStorage copies actual
      // bytes via path_provider (its local-copy step is NOT stubbed here).
      final tempDir = await getTemporaryDirectory();
      final sourcePath = p.join(
        tempDir.path,
        'scan_src_${DateTime.now().microsecondsSinceEpoch}.jpg',
      );
      await File(sourcePath).writeAsBytes(
        List<int>.generate(64, (i) => i),
        flush: true,
      );
      addTearDown(() async {
        final f = File(sourcePath);
        if (f.existsSync()) await f.delete();
      });

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
          GoRoute(
            path: AppRoutes.history,
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            path: AppRoutes.recordBp,
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('RECORD BP STUB'))),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            textRecognitionServiceProvider.overrideWithValue(ocr),
          ],
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );

      // OCR runs in initState(); wait for the parsed reading to render.
      await _pumpUntil(tester, find.text('136/84 mmHg'));
      expect(ocr.calls, 1);
      expect(find.text('Needs review'), findsOneWidget);

      await tester.tap(find.text('Confirm and save'));
      await _pumpUntil(tester, find.text('SAVED REPORTS STUB'));

      // The report row is in real SQLite, and its page file was copied out
      // of the temp dir into the app's support directory.
      final reports = await db.select(db.savedReports).get();
      expect(reports, hasLength(1));
      final savedPagePath = reports.single.localPagePaths;
      expect(savedPagePath, isNot(contains(sourcePath)));
      expect(File(savedPagePath).existsSync(), isTrue);
      addTearDown(() async {
        final f = File(savedPagePath);
        if (f.existsSync()) await f.delete();
      });

      // The confirmed reading is in BP History storage, tagged as imported.
      final readings = await db.select(db.readings).get();
      expect(readings, hasLength(1));
      expect(readings.single.systolic, 136);
      expect(readings.single.diastolic, 84);
      expect(readings.single.pulse, 72);
      expect(readings.single.source, 'importedReport');
      expect(readings.single.sourceReportId, reports.single.id);

      // And it renders on the real History screen.
      router.go(AppRoutes.history);
      await _pumpUntil(tester, find.text('136/84'));
    },
  );
}

Future<void> _pumpUntil(
  WidgetTester tester,
  Finder finder, {
  int tries = 80,
}) async {
  for (var i = 0; i < tries; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  expect(finder, findsWidgets);
}
