import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/core/paywall/paywall_providers.dart';
import 'package:vitality/features/blood_pressure/data/app_database.dart';
import 'package:vitality/features/blood_pressure/data/blood_pressure_providers.dart';
import 'package:vitality/features/blood_pressure/data/drift_blood_pressure_repository.dart';
import 'package:vitality/features/data_export/presentation/export_data_screen.dart';

import '../../../support/fake_paywall_service.dart';
import '../../../support/pump_app.dart';

void main() {
  Future<AppDatabase> seed({required int recentDays}) async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = DriftBloodPressureRepository(db);
    final now = DateTime.now();
    await repo.addReading(
      systolic: 122,
      diastolic: 80,
      pulse: 70,
      timestamp: now.subtract(Duration(days: recentDays)),
    );
    await repo.addReading(
      systolic: 140,
      diastolic: 90,
      timestamp: now.subtract(const Duration(days: 200)),
    );
    return db;
  }

  Future<void> pumpScreen(
    WidgetTester tester,
    AppDatabase db, {
    List<Override> overrides = const [],
  }) async {
    tester.view.physicalSize = const Size(500, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db), ...overrides],
        child: const MaterialApp(
          localizationsDelegates: localizationWrappers,
          supportedLocales: testSupportedLocales,
          home: ExportDataScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('renders the sections and the format options', (tester) async {
    final db = await seed(recentDays: 3);
    addTearDown(db.close);
    await pumpScreen(tester, db);

    expect(find.text('Export data'), findsOneWidget);
    expect(find.text('DATE RANGE'), findsOneWidget);
    expect(find.text('FORMAT'), findsOneWidget);
    expect(find.text('PDF summary'), findsOneWidget);
    expect(find.text('CSV spreadsheet'), findsOneWidget);
    expect(find.text('Full archive'), findsOneWidget);
    expect(find.text('Include notes and tags'), findsOneWidget);
    // Only the in-window reading counts toward the default 30-day range.
    expect(find.text('Export 1 reading'), findsOneWidget);

    await db.close();
  });

  testWidgets('widening the date range brings the older reading into scope', (tester) async {
    final db = await seed(recentDays: 3);
    addTearDown(db.close);
    await pumpScreen(tester, db);

    expect(find.text('Export 1 reading'), findsOneWidget);

    // The date-range chips scroll horizontally; "All time" is the last one.
    await tester.ensureVisible(find.text('All time'));
    await tester.pump();
    await tester.tap(find.text('All time'));
    await tester.pump();

    expect(find.text('Export 2 readings'), findsOneWidget);

    await db.close();
  });

  testWidgets('the export button is disabled when the range is empty', (tester) async {
    // Both readings are >90 days old, so the default "Last 30 days" is empty.
    final db = await seed(recentDays: 120);
    addTearDown(db.close);
    await pumpScreen(tester, db);

    expect(find.textContaining('No readings in this range'), findsOneWidget);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);

    await db.close();
  });

  testWidgets(
    'tapping Export does not generate a file when the paywall denies access (export_report_data placement)',
    (tester) async {
      final db = await seed(recentDays: 3);
      addTearDown(db.close);
      final paywall = FakePaywallService(grantsAccess: false);
      await pumpScreen(
        tester,
        db,
        overrides: [paywallServiceProvider.overrideWithValue(paywall)],
      );

      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(paywall.registeredPlacements, ['export_report_data']);
      // The export flow never ran, so the button never entered its busy
      // (file-generation-in-progress) state.
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await db.close();
    },
  );

  testWidgets(
    'tapping Export attempts to generate a file when the paywall grants access (export_report_data placement)',
    (tester) async {
      final db = await seed(recentDays: 3);
      addTearDown(db.close);
      final paywall = FakePaywallService(grantsAccess: true);
      await pumpScreen(
        tester,
        db,
        overrides: [paywallServiceProvider.overrideWithValue(paywall)],
      );

      // Not pumpAndSettle()/a longer wait: the share/save plugins have no
      // test-harness implementation, so the real export call this kicks
      // off never resolves. One pump is enough to observe that the gated
      // flow actually started (rather than being skipped).
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(paywall.registeredPlacements, ['export_report_data']);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await db.close();
    },
  );
}
