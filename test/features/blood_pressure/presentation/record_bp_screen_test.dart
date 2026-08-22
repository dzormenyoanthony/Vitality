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

    await tester.enterText(find.widgetWithText(TextFormField, 'Systolic'), '999');
    await tester.enterText(find.widgetWithText(TextFormField, 'Diastolic'), '80');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pump();

    expect(find.text('Systolic must be between 60 and 260 mmHg.'), findsOneWidget);
  });
}
