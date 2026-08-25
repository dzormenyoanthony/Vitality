import 'package:drift/native.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/blood_pressure/data/app_database.dart';
import 'package:vitality/features/blood_pressure/data/blood_pressure_providers.dart';
import 'package:vitality/features/blood_pressure/data/drift_blood_pressure_repository.dart';
import 'package:vitality/features/blood_pressure/presentation/trends_screen.dart';

void main() {
  testWidgets('shows the empty state when there are no readings in the period', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: TrendsScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('No readings in this period yet.'), findsOneWidget);

    await db.close();
  });

  testWidgets('shows non-diagnostic average and count copy for the default 7-day period', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = DriftBloodPressureRepository(db);
    await repository.addReading(systolic: 120, diastolic: 80, timestamp: DateTime.now());
    await repository.addReading(
      systolic: 130,
      diastolic: 90,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: TrendsScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('125 / 85'), findsOneWidget);
    expect(find.textContaining('on 2 of 7 days'), findsOneWidget);

    await db.close();
  });

  testWidgets('switching to the 90-day period updates the displayed stats', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = DriftBloodPressureRepository(db);
    // Outside the 7-day window, inside the 90-day window.
    await repository.addReading(
      systolic: 140,
      diastolic: 95,
      timestamp: DateTime.now().subtract(const Duration(days: 20)),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: TrendsScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('No readings in this period yet.'), findsOneWidget);

    await tester.tap(find.text('90 d'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('140 / 95'), findsOneWidget);

    await db.close();
  });

  testWidgets('the trend chart exposes a screen-reader description (PROJECT_SPEC.md §35)', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = DriftBloodPressureRepository(db);
    await repository.addReading(systolic: 120, diastolic: 80, timestamp: DateTime.now());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: TrendsScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final semantics = tester.getSemantics(find.byType(LineChart).first);
    expect(semantics.label, isNotEmpty);

    handle.dispose();
    await db.close();
  });

  testWidgets('offers 7/30/90-day and 1-year period chips', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: TrendsScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('7 d'), findsOneWidget);
    expect(find.text('30 d'), findsOneWidget);
    expect(find.text('90 d'), findsOneWidget);
    expect(find.text('1 y'), findsOneWidget);

    await db.close();
  });

  testWidgets('shows an export-summary button once there are readings', (tester) async {
    // The stat grid + disclaimer pushed the export button below the default
    // 600px test-surface height, so it wouldn't be built by the (lazy)
    // ListView without this taller viewport.
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await DriftBloodPressureRepository(db).addReading(
      systolic: 120,
      diastolic: 80,
      timestamp: DateTime.now(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: TrendsScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.widgetWithText(OutlinedButton, 'Export 7-day summary (PDF)'), findsOneWidget);

    await db.close();
  });
}
