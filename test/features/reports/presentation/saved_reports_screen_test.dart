import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:vitality/features/blood_pressure/data/app_database.dart';
import 'package:vitality/features/blood_pressure/data/blood_pressure_providers.dart';
import 'package:vitality/features/reports/data/drift_saved_report_repository.dart';
import 'package:vitality/features/reports/domain/extracted_reading.dart';
import 'package:vitality/features/reports/domain/saved_report.dart';
import 'package:vitality/features/reports/presentation/saved_reports_screen.dart';

void main() {
  testWidgets('shows the empty state when there are no saved reports', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: SavedReportsScreen()),
      ),
    );
    await tester.pump();

    expect(find.textContaining('No saved reports yet'), findsOneWidget);

    await db.close();
  });

  testWidgets(
    'lists a saved report with its date, type, and category chip count',
    (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await DriftSavedReportRepository(db).add(
        title: 'Scanned report',
        documentType: ReportDocumentType.image,
        reportDate: DateTime(2026, 8, 22),
        pageCount: 2,
        ocrStatus: OcrStatus.succeeded,
        confirmedReadings: const [
          ExtractedReading(id: 0, systolic: 136, diastolic: 84),
        ],
        source: ReportSource.scan,
        localPagePaths: ['/tmp/page_0.jpg', '/tmp/page_1.jpg'],
        category: ReportCategory.labResults,
        provider: 'Northside Lab',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: const MaterialApp(home: SavedReportsScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Scanned report'), findsOneWidget);
      expect(find.textContaining('22 Aug'), findsOneWidget);
      expect(find.textContaining('Northside Lab'), findsOneWidget);
      expect(find.text('All 1'), findsOneWidget);
      expect(find.text('Lab results 1'), findsOneWidget);

      await db.close();
    },
  );

  testWidgets('tapping a category chip filters the list to that category', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = DriftSavedReportRepository(db);
    await repository.add(
      title: 'Ambulatory BP monitor',
      documentType: ReportDocumentType.pdf,
      pageCount: 1,
      ocrStatus: OcrStatus.notProcessed,
      source: ReportSource.scan,
      localPagePaths: const ['/tmp/bp.pdf'],
      category: ReportCategory.bpReport,
    );
    await repository.add(
      title: 'Lipid panel & metabolic',
      documentType: ReportDocumentType.pdf,
      pageCount: 1,
      ocrStatus: OcrStatus.notProcessed,
      source: ReportSource.import,
      localPagePaths: const ['/tmp/lipid.pdf'],
      category: ReportCategory.labResults,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: SavedReportsScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Ambulatory BP monitor'), findsOneWidget);
    expect(find.text('Lipid panel & metabolic'), findsOneWidget);

    await tester.tap(find.text('Lab results 1'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Lipid panel & metabolic'), findsOneWidget);
    expect(find.text('Ambulatory BP monitor'), findsNothing);

    await db.close();
  });

  testWidgets('deleting a report removes it from the list', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await DriftSavedReportRepository(db).add(
      title: 'Scanned report',
      documentType: ReportDocumentType.image,
      pageCount: 1,
      ocrStatus: OcrStatus.notProcessed,
      source: ReportSource.scan,
      localPagePaths: ['/tmp/page_0.jpg'],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: SavedReportsScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // A fixed-duration pump instead of pumpAndSettle(): this screen watches
    // a live Drift stream (savedReportsStreamProvider), which reproducibly
    // hangs pumpAndSettle() in this environment — same reasoning documented
    // in test/core/router/app_router_flow_test.dart's `_settle` helper.
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Delete'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Scanned report'), findsNothing);
    expect(find.textContaining('No saved reports yet'), findsOneWidget);

    await db.close();
  });

  testWidgets('the back button returns to Dashboard when there is nothing to pop', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final router = GoRouter(
      initialLocation: '/saved-reports',
      routes: [
        GoRoute(path: '/saved-reports', builder: (context, state) => const SavedReportsScreen()),
        GoRoute(path: '/dashboard', builder: (context, state) => const Scaffold(body: Text('Dashboard'))),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();

    // Reached as the stack root (as it would be via `context.go` from the
    // scan/confirm flow) — no default AppBar back button would show here,
    // but the explicit one must still be present and working.
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Dashboard'), findsOneWidget);

    await db.close();
  });
}
