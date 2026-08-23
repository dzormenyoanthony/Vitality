import 'package:drift/native.dart';
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

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
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

  testWidgets('multiple context chips can be selected at once', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
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

    await tester.tap(find.widgetWithText(FilterChip, 'Morning'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilterChip, 'Before medication'));
    await tester.pump();

    expect(
      tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'Morning')).selected,
      isTrue,
    );
    expect(
      tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'Before medication')).selected,
      isTrue,
    );
    expect(
      tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'After exercise')).selected,
      isFalse,
    );
  });

  testWidgets('body position and cuff arm fields are present and selectable', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
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

    expect(
      find.widgetWithText(DropdownButtonFormField<BodyPosition?>, 'Body position (optional)'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(DropdownButtonFormField<CuffArm?>, 'Cuff arm (optional)'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(DropdownButtonFormField<BodyPosition?>, 'None').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sitting').last);
    await tester.pumpAndSettle();

    expect(find.text('Sitting'), findsOneWidget);
  });
}
