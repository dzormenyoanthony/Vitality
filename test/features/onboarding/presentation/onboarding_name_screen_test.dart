import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/onboarding/presentation/onboarding_name_screen.dart';

void main() {
  testWidgets('requires a non-empty name before submitting', (tester) async {
    var submittedName = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OnboardingNameScreen(
            onSubmit: (name) => submittedName = name,
            isSubmitting: false,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(find.text('Enter a preferred name.'), findsOneWidget);
    expect(submittedName, isEmpty);

    await tester.enterText(find.byType(TextFormField), 'Alex');
    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(submittedName, 'Alex');
  });

  testWidgets('shows the provided error message', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OnboardingNameScreen(
            onSubmit: (_) {},
            isSubmitting: false,
            errorMessage: 'Something went wrong. Please try again.',
          ),
        ),
      ),
    );

    expect(find.text('Something went wrong. Please try again.'), findsOneWidget);
  });
}
