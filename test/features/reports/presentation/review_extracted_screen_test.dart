import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:vitality/features/blood_pressure/data/app_database.dart';
import 'package:vitality/features/blood_pressure/data/blood_pressure_providers.dart';
import 'package:vitality/features/reports/data/report_document_storage.dart';
import 'package:vitality/features/reports/data/report_providers.dart';
import 'package:vitality/features/reports/domain/saved_report.dart';
import 'package:vitality/features/reports/domain/text_recognition_service.dart';
import 'package:vitality/features/reports/presentation/review_extracted_screen.dart';

class _FakeTextRecognitionService implements TextRecognitionService {
  _FakeTextRecognitionService(this.textByPath);

  final Map<String, String> textByPath;
  bool shouldFail = false;

  @override
  Future<String> recognizeText(String imagePath) async {
    if (shouldFail) throw Exception('OCR failed');
    return textByPath[imagePath] ?? '';
  }

  @override
  Future<void> dispose() async {}
}

/// Avoids real `path_provider`/file-system/network calls (unavailable in a
/// widget test) — pretends the source paths are already permanent, and
/// that upload never happens.
class _FakeReportDocumentStorage extends ReportDocumentStorage {
  @override
  Future<List<String>> saveLocalPages({required List<String> sourcePaths}) async {
    return sourcePaths;
  }

  @override
  Future<List<String>?> uploadPages({
    required int reportId,
    required List<String> localPagePaths,
  }) async {
    return null;
  }
}

void main() {
  testWidgets('runs OCR and lists a detected reading with a "Needs review" tag', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final fakeOcr = _FakeTextRecognitionService({'/tmp/page_0.jpg': '136/84 mmHg\nPulse 72 bpm'});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          textRecognitionServiceProvider.overrideWithValue(fakeOcr),
        ],
        child: MaterialApp(
          home: ReviewExtractedScreen(
            args: const ReviewExtractedArgs(
              rawPagePaths: ['/tmp/page_0.jpg'],
              documentType: ReportDocumentType.image,
              source: ReportSource.scan,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('136/84 mmHg'), findsOneWidget);
    expect(find.text('Needs review'), findsOneWidget);
    expect(find.textContaining('Pulse 72 bpm'), findsOneWidget);
    final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(checkbox.value, isTrue);

    await db.close();
  });

  testWidgets('deleting the only reading removes it from the list', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final fakeOcr = _FakeTextRecognitionService({'/tmp/page_0.jpg': '136/84 mmHg'});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          textRecognitionServiceProvider.overrideWithValue(fakeOcr),
        ],
        child: MaterialApp(
          home: ReviewExtractedScreen(
            args: const ReviewExtractedArgs(
              rawPagePaths: ['/tmp/page_0.jpg'],
              documentType: ReportDocumentType.image,
              source: ReportSource.scan,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump();

    expect(find.text('136/84 mmHg'), findsNothing);
    expect(find.textContaining('No blood pressure readings were detected'), findsOneWidget);

    await db.close();
  });

  testWidgets('shows the OCR-failure state with a save-without-info option', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final fakeOcr = _FakeTextRecognitionService({})..shouldFail = true;

    final router = GoRouter(
      initialLocation: '/review',
      routes: [
        GoRoute(
          path: '/review',
          builder: (context, state) => ReviewExtractedScreen(
            args: const ReviewExtractedArgs(
              rawPagePaths: ['/tmp/page_0.jpg'],
              documentType: ReportDocumentType.image,
              source: ReportSource.scan,
            ),
          ),
        ),
        GoRoute(path: '/saved-reports', builder: (context, state) => const Scaffold(body: Text('Saved'))),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          textRecognitionServiceProvider.overrideWithValue(fakeOcr),
          reportDocumentStorageProvider.overrideWithValue(_FakeReportDocumentStorage()),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text("We couldn't reliably read this report."), findsOneWidget);
    expect(find.text('Save report without extracted info'), findsOneWidget);

    await tester.tap(find.text('Save report without extracted info'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Saved'), findsOneWidget);

    final reports = await db.select(db.savedReports).get();
    expect(reports, hasLength(1));
    expect(reports.single.ocrStatus, 'failed');
    expect(reports.single.localPagePaths, '/tmp/page_0.jpg');
    // OCR failure must never block saving the original document, and must
    // never add anything to BP History (PROJECT_SPEC.md "Scan BP Report"
    // §6, §13).
    final readings = await db.select(db.readings).get();
    expect(readings, isEmpty);

    await db.close();
  });

  testWidgets('confirming a detected reading adds it to BP History as an imported reading', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final fakeOcr = _FakeTextRecognitionService({'/tmp/page_0.jpg': '136/84 mmHg'});

    final router = GoRouter(
      initialLocation: '/review',
      routes: [
        GoRoute(
          path: '/review',
          builder: (context, state) => ReviewExtractedScreen(
            args: const ReviewExtractedArgs(
              rawPagePaths: ['/tmp/page_0.jpg'],
              documentType: ReportDocumentType.image,
              source: ReportSource.scan,
            ),
          ),
        ),
        GoRoute(path: '/saved-reports', builder: (context, state) => const Scaffold(body: Text('Saved'))),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          textRecognitionServiceProvider.overrideWithValue(fakeOcr),
          reportDocumentStorageProvider.overrideWithValue(_FakeReportDocumentStorage()),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('Confirm and save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Saved'), findsOneWidget);

    final reports = await db.select(db.savedReports).get();
    expect(reports.single.confirmedReadingsJson, contains('136'));

    final readings = await db.select(db.readings).get();
    expect(readings, hasLength(1));
    expect(readings.single.systolic, 136);
    expect(readings.single.diastolic, 84);
    expect(readings.single.source, 'importedReport');
    expect(readings.single.sourceReportId, reports.single.id);

    await db.close();
  });
}
