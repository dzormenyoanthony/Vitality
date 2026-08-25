import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/authentication/data/auth_providers.dart';
import 'package:vitality/features/authentication/data/fake_auth_repository.dart';
import 'package:vitality/features/authentication/presentation/sign_in_screen.dart';
import 'package:vitality/features/authentication/presentation/sign_up_screen.dart';

void main() {
  group('SignInScreen', () {
    testWidgets('shows validation errors for empty fields', (tester) async {
      final authRepository = FakeAuthRepository();
      addTearDown(authRepository.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(authRepository)],
          child: const MaterialApp(home: SignInScreen()),
        ),
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pump();

      expect(find.text('Enter your email address.'), findsOneWidget);
      expect(find.text('Enter your password.'), findsOneWidget);
    });

    testWidgets('shows a friendly error message on failed sign-in', (
      tester,
    ) async {
      final authRepository = FakeAuthRepository();
      addTearDown(authRepository.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(authRepository)],
          child: const MaterialApp(home: SignInScreen()),
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'nobody@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'wrongpass',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('Incorrect email or password.'), findsOneWidget);
    });
  });

  group('SignUpScreen', () {
    testWidgets('rejects a password shorter than the minimum', (tester) async {
      final authRepository = FakeAuthRepository();
      addTearDown(authRepository.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(authRepository)],
          child: const MaterialApp(home: SignUpScreen()),
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'EMAIL'),
        'new@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'PASSWORD'),
        '123',
      );
      await tester.ensureVisible(
        find.widgetWithText(FilledButton, 'Create account'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
      await tester.pump();

      expect(
        find.text('Password must be at least 6 characters.'),
        findsOneWidget,
      );
    });

    testWidgets('rejects a confirm password that does not match', (
      tester,
    ) async {
      final authRepository = FakeAuthRepository();
      addTearDown(authRepository.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(authRepository)],
          child: const MaterialApp(home: SignUpScreen()),
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'EMAIL'),
        'new@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'PASSWORD'),
        'password123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'CONFIRM PASSWORD'),
        'password456',
      );
      await tester.ensureVisible(
        find.widgetWithText(FilledButton, 'Create account'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
      await tester.pump();

      expect(find.text('Passwords do not match.'), findsOneWidget);
      expect(authRepository.currentUser, isNull);
    });

    testWidgets('signs in with Google via the Continue with Google button', (
      tester,
    ) async {
      final authRepository = FakeAuthRepository();
      addTearDown(authRepository.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(authRepository)],
          child: const MaterialApp(home: SignUpScreen()),
        ),
      );

      expect(authRepository.currentUser, isNull);

      await tester.tap(
        find.widgetWithText(OutlinedButton, 'Continue with Google'),
      );
      await tester.pumpAndSettle();

      expect(authRepository.currentUser, isNotNull);
    });
  });
}
