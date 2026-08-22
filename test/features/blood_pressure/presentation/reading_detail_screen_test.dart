import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/blood_pressure/data/app_database.dart';
import 'package:vitality/features/blood_pressure/data/blood_pressure_providers.dart';
import 'package:vitality/features/blood_pressure/data/blood_pressure_reading.dart';
import 'package:vitality/features/blood_pressure/data/drift_blood_pressure_repository.dart';
import 'package:vitality/features/blood_pressure/presentation/reading_detail_screen.dart';

// This covers rendering only. Interacting with the delete confirmation
// dialog (any Navigator/dialog route change) combined with watching a live
// Drift native stream reproducibly hangs flutter_test in this environment
// — confirmed independent of GoRouter, of the exact navigation pattern,
// and of running with `dart_test.yaml`'s concurrency:1. Isolated
// Drift-stream widgets and isolated Navigator/dialog transitions are each
// reliable on their own; only the combination hangs. Delete/cancel
// correctness at the data layer is covered by
// drift_blood_pressure_repository_test.dart; the full interactive UX
// (open dialog, cancel, confirm, navigate back) is verified manually on
// device instead.
void main() {
  testWidgets("shows the reading's details from the live stream", (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = DriftBloodPressureRepository(db);
    final id = await repository.addReading(
      systolic: 128,
      diastolic: 82,
      pulse: 68,
      timestamp: DateTime(2026, 1, 5, 7, 15),
      notes: 'Before breakfast',
      measurementContext: MeasurementContext.morning,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(home: ReadingDetailScreen(readingId: id)),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('128/82 mmHg'), findsOneWidget);
    expect(find.text('68 bpm'), findsOneWidget);
    expect(find.text('Morning'), findsOneWidget);
    expect(find.text('Before breakfast'), findsOneWidget);

    // Closing the database directly lets Drift's stream cleanup complete
    // as part of this awaited call, rather than firing a zero-duration
    // Timer that flutter_test's teardown never gets a chance to flush.
    await db.close();
  });
}
