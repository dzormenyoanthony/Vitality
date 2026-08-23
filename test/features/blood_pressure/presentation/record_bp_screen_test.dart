import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/blood_pressure/data/app_database.dart';
import 'package:vitality/features/blood_pressure/data/blood_pressure_providers.dart';
import 'package:vitality/features/blood_pressure/presentation/record_bp_screen.dart';

void main() {
  testWidgets('shows validation errors when required fields are empty', (
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

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pump();

    expect(find.text('Enter a systolic value.'), findsOneWidget);
    expect(find.text('Enter a diastolic value.'), findsOneWidget);
  });

  testWidgets('shows a range error for an out-of-range systolic value', (
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

    await tester.enterText(find.widgetWithText(TextFormField, 'Systolic (mmHg)'), '999');
    await tester.enterText(find.widgetWithText(TextFormField, 'Diastolic (mmHg)'), '80');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
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

  testWidgets('date & time shows a formatted timestamp, not a raw DateTime.toString()', (
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

    final subtitle = tester
        .widget<Text>(
          find.descendant(of: find.widgetWithText(ListTile, 'Date & time'), matching: find.byType(Text)).last,
        )
        .data!;
    expect(subtitle, isNot(contains('.'))); // no raw millisecond fraction
    expect(subtitle, matches(RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$')));
  });
}
