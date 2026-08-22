import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/reminders/presentation/reminder_form_screen.dart';

void main() {
  testWidgets('shows a validation error when the label is empty', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ReminderFormScreen())),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pump();

    expect(find.text('Enter a label.'), findsOneWidget);
  });

  testWidgets('shows a validation error when no day is selected', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ReminderFormScreen())),
    );

    await tester.enterText(find.widgetWithText(TextFormField, 'Label'), 'Evening reading');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pump();

    expect(find.text('Select at least one day.'), findsOneWidget);
  });

  testWidgets('"Every day" selects all seven day chips', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ReminderFormScreen())),
    );

    await tester.tap(find.text('Every day'));
    await tester.pump();

    for (final label in ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']) {
      final chip = tester.widget<FilterChip>(find.widgetWithText(FilterChip, label));
      expect(chip.selected, isTrue, reason: '$label should be selected');
    }
  });
}
