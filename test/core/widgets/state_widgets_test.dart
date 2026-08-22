import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/core/widgets/empty_view.dart';
import 'package:vitality/core/widgets/error_view.dart';
import 'package:vitality/core/widgets/loading_indicator.dart';

void main() {
  group('LoadingIndicator', () {
    testWidgets('shows a progress indicator and optional message', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoadingIndicator(message: 'Loading data'),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading data'), findsOneWidget);
    });
  });

  group('ErrorView', () {
    testWidgets('shows the message and invokes onRetry when tapped', (
      tester,
    ) async {
      var retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorView(
            message: 'Something went wrong.',
            onRetry: () => retried = true,
          ),
        ),
      );

      expect(find.text('Something went wrong.'), findsOneWidget);
      await tester.tap(find.text('Try again'));
      await tester.pump();

      expect(retried, isTrue);
    });

    testWidgets('hides the retry button when onRetry is not provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: ErrorView(message: 'Failed.')),
      );

      expect(find.text('Try again'), findsNothing);
    });
  });

  group('EmptyView', () {
    testWidgets('shows the provided message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: EmptyView(message: 'Nothing here yet.')),
      );

      expect(find.text('Nothing here yet.'), findsOneWidget);
    });
  });
}
