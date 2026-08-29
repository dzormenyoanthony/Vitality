import 'package:drift/native.dart';
import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/blood_pressure/data/app_database.dart';
import 'package:vitality/features/blood_pressure/data/blood_pressure_providers.dart';
import 'package:vitality/features/blood_pressure/data/blood_pressure_reading.dart';
import 'package:vitality/features/blood_pressure/presentation/record_bp_screen.dart';

void main() {
  testWidgets('shows validation errors when required fields are empty', (
    tester,
  ) async {
    // The form is taller than the default test viewport now that it has
    // body-position/cuff-arm fields and context chips; enlarge it so the
    // Save button is actually hit-testable without scrolling.
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: RecordBpScreen()),
      ),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Save reading'));
    await tester.pump();

    expect(find.text('Enter a systolic value.'), findsOneWidget);
    expect(find.text('Enter a diastolic value.'), findsOneWidget);
  });

  testWidgets('shows a range error for an out-of-range systolic value', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: RecordBpScreen()),
      ),
    );

    await tester.enterText(find.widgetWithText(TextFormField, 'Systolic (mmHg)'), '999');
    await tester.enterText(find.widgetWithText(TextFormField, 'Diastolic (mmHg)'), '80');
    await tester.tap(find.widgetWithText(FilledButton, 'Save reading'));
    await tester.pump();

    expect(find.text('Systolic must be between 60 and 260 mmHg.'), findsOneWidget);
  });

  testWidgets('field labels announce units for screen readers (PROJECT_SPEC.md §35)', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: RecordBpScreen()),
      ),
    );

    // suffixText alone isn't exposed to the field's semantics node, so the
    // unit must be part of the label itself.
    expect(find.widgetWithText(TextFormField, 'Systolic (mmHg)'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Diastolic (mmHg)'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Pulse (optional, bpm)'), findsOneWidget);
  });

  testWidgets('date & time shows a friendly formatted timestamp with a Change button', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: RecordBpScreen()),
      ),
    );

    expect(find.widgetWithText(TextButton, 'Change'), findsOneWidget);
    // Friendly locale-formatted stamp, e.g. "Tue, Jan 5, 2026 · 07:15"
    // (en_US skeleton) — not a raw DateTime.toString().
    expect(
      find.textContaining(
        RegExp(r'^\w{3}, \w{3} \d{1,2}, \d{4} · \d{2}:\d{2}$'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('multiple context chips can be selected at once', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final handle = tester.ensureSemantics();

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: RecordBpScreen()),
      ),
    );

    await tester.tap(find.text('Morning'));
    await tester.pump();
    await tester.tap(find.text('Before medication'));
    await tester.pump();

    expect(
      tester.getSemantics(find.text('Morning')).flagsCollection.isSelected == Tristate.isTrue,
      isTrue,
    );
    expect(
      tester.getSemantics(find.text('Before medication')).flagsCollection.isSelected == Tristate.isTrue,
      isTrue,
    );
    expect(
      tester.getSemantics(find.text('After exercise')).flagsCollection.isSelected == Tristate.isTrue,
      isFalse,
    );

    handle.dispose();
  });

  testWidgets('body position chip and cuff arm dropdown are present and selectable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final handle = tester.ensureSemantics();

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: RecordBpScreen()),
      ),
    );

    expect(
      find.widgetWithText(DropdownButtonFormField<CuffArm?>, 'Cuff arm (optional)'),
      findsOneWidget,
    );

    // Body position is a single-select chip merged into the context row.
    expect(
      tester.getSemantics(find.text('Sitting')).flagsCollection.isSelected == Tristate.isTrue,
      isFalse,
    );
    await tester.tap(find.text('Sitting'));
    await tester.pump();
    expect(
      tester.getSemantics(find.text('Sitting')).flagsCollection.isSelected == Tristate.isTrue,
      isTrue,
    );

    await tester.tap(find.widgetWithText(DropdownButtonFormField<CuffArm?>, 'None').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Left arm').last);
    await tester.pumpAndSettle();

    expect(find.text('Left arm'), findsOneWidget);

    handle.dispose();
  });
}
