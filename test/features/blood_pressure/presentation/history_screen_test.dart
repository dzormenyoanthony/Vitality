import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/blood_pressure/data/app_database.dart';
import 'package:vitality/features/blood_pressure/data/blood_pressure_providers.dart';
import 'package:vitality/features/blood_pressure/data/drift_blood_pressure_repository.dart';
import 'package:vitality/features/blood_pressure/presentation/history_screen.dart';

void main() {
  testWidgets('shows the empty state when there are no readings', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: HistoryScreen()),
      ),
    );
    await tester.pump();

    expect(
      find.text('No readings yet. Tap + to record your first blood pressure reading.'),
      findsOneWidget,
    );

    // Closing the database directly lets Drift's stream cleanup complete
    // as part of this awaited call, rather than firing a zero-duration
    // Timer during flutter_test's teardown that never gets flushed.
    await db.close();
  });

  testWidgets('lists a reading once one has been recorded', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await DriftBloodPressureRepository(db).addReading(
      systolic: 120,
      diastolic: 80,
      pulse: 70,
      timestamp: DateTime(2026, 1, 1, 8, 30),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: HistoryScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('120/80'), findsOneWidget);
    expect(find.text('70 bpm'), findsOneWidget);

    await db.close();
  });

  testWidgets('the Morning filter hides an evening-only reading', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = DriftBloodPressureRepository(db);
    await repository.addReading(
      systolic: 120,
      diastolic: 80,
      timestamp: DateTime(2026, 1, 1, 8), // morning
    );
    await repository.addReading(
      systolic: 130,
      diastolic: 85,
      timestamp: DateTime(2026, 1, 1, 21), // evening
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: HistoryScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('120/80'), findsOneWidget);
    expect(find.text('130/85'), findsOneWidget);

    await tester.tap(find.text('Morning'));
    await tester.pump();

    expect(find.text('120/80'), findsOneWidget);
    expect(find.text('130/85'), findsNothing);

    await db.close();
  });

  testWidgets('swiping a row right shows the delete confirmation dialog', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await DriftBloodPressureRepository(db).addReading(
      systolic: 120,
      diastolic: 80,
      timestamp: DateTime(2026, 1, 1, 8),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: HistoryScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.drag(find.text('120/80'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(find.text('Delete this reading?'), findsOneWidget);

    // Cancel so the row survives and Drift's stream can tear down cleanly.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await db.close();
  });
}
