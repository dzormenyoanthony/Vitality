import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vitality/core/services/shared_preferences_provider.dart';
import 'package:vitality/features/authentication/data/auth_providers.dart';
import 'package:vitality/features/authentication/data/fake_auth_repository.dart';
import 'package:vitality/features/authentication/presentation/sign_in_screen.dart';
import 'package:vitality/features/authentication/presentation/sign_up_screen.dart';

import '../../../support/pump_app.dart';

void main() {
  group('SignInScreen', () {
    // SignInScreen reads sharedPreferencesProvider for the "Keep me signed
    // in" checkbox, so every test needs a mocked instance overridden in.
    Future<SharedPreferences> mockPrefs() async {
      SharedPreferences.setMockInitialValues({});
      return SharedPreferences.getInstance();
    }

    testWidgets('shows validation errors for empty fields', (tester) async {
      final authRepository = FakeAuthRepository();
      addTearDown(authRepository.dispose);
      final prefs = await mockPrefs();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(authRepository),
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(
            localizationsDelegates: localizationWrappers,
            supportedLocales: testSupportedLocales,
            home: SignInScreen(),
          ),
        ),
      );

      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pump();
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
      final prefs = await mockPrefs();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(authRepository),
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(
            localizationsDelegates: localizationWrappers,
            supportedLocales: testSupportedLocales,
            home: SignInScreen(),
          ),
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'EMAIL'),
        'nobody@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'PASSWORD'),
        'wrongpass',
      );
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('Incorrect email or password.'), findsOneWidget);
    });

    testWidgets('signs in with Google via the Continue with Google button', (
      tester,
    ) async {
      final authRepository = FakeAuthRepository();
      addTearDown(authRepository.dispose);
      final prefs = await mockPrefs();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(authRepository),
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(
            localizationsDelegates: localizationWrappers,
            supportedLocales: testSupportedLocales,
            home: SignInScreen(),
          ),
        ),
      );

      expect(authRepository.currentUser, isNull);

      await tester.tap(
        find.widgetWithText(OutlinedButton, 'Continue with Google'),
      );
      await tester.pumpAndSettle();

      expect(authRepository.currentUser, isNotNull);
    });

    testWidgets(
      'cancelling the Google account picker does not show an error message',
      (tester) async {
        final authRepository = FakeAuthRepository()..simulateGoogleCancel = true;
        addTearDown(authRepository.dispose);
        final prefs = await mockPrefs();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authRepositoryProvider.overrideWithValue(authRepository),
              sharedPreferencesProvider.overrideWithValue(prefs),
            ],
            child: const MaterialApp(
            localizationsDelegates: localizationWrappers,
            supportedLocales: testSupportedLocales,
            home: SignInScreen(),
          ),
          ),
        );

        await tester.tap(
          find.widgetWithText(OutlinedButton, 'Continue with Google'),
        );
        await tester.pumpAndSettle();

        expect(authRepository.currentUser, isNull);
        expect(find.text('Sign-in was cancelled.'), findsNothing);
      },
    );

    testWidgets(
      'does not overflow at a large system text scale on a large phone (regression)',
      (tester) async {
        // Roughly a 6.7" phone at 3x device pixel ratio — a tester reported
        // the sign-in form cut off at the bottom half of the screen with a
        // large text-size accessibility setting on a device this size.
        tester.view.physicalSize = const Size(1220, 2712);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.reset);

        final authRepository = FakeAuthRepository();
        addTearDown(authRepository.dispose);
        final prefs = await mockPrefs();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authRepositoryProvider.overrideWithValue(authRepository),
              sharedPreferencesProvider.overrideWithValue(prefs),
            ],
            child: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
              child: const MaterialApp(
                localizationsDelegates: localizationWrappers,
                supportedLocales: testSupportedLocales,
                home: SignInScreen(),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'unchecking "Keep me signed in" persists the preference as false',
      (tester) async {
        final authRepository = FakeAuthRepository();
        addTearDown(authRepository.dispose);
        final prefs = await mockPrefs();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authRepositoryProvider.overrideWithValue(authRepository),
              sharedPreferencesProvider.overrideWithValue(prefs),
            ],
            child: const MaterialApp(
            localizationsDelegates: localizationWrappers,
            supportedLocales: testSupportedLocales,
            home: SignInScreen(),
          ),
          ),
        );

        expect(prefs.getBool('keep_signed_in'), isNull);

        await tester.ensureVisible(find.byType(Checkbox));
        await tester.pump();
        await tester.tap(find.byType(Checkbox));
        await tester.pump();

        expect(prefs.getBool('keep_signed_in'), isFalse);
      },
    );
  });

  group('SignUpScreen', () {
    testWidgets('rejects a password shorter than the minimum', (tester) async {
      final authRepository = FakeAuthRepository();
      addTearDown(authRepository.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(authRepository)],
          child: const MaterialApp(
            localizationsDelegates: localizationWrappers,
            supportedLocales: testSupportedLocales,
            home: SignUpScreen(),
          ),
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
          child: const MaterialApp(
            localizationsDelegates: localizationWrappers,
            supportedLocales: testSupportedLocales,
            home: SignUpScreen(),
          ),
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
          child: const MaterialApp(
            localizationsDelegates: localizationWrappers,
            supportedLocales: testSupportedLocales,
            home: SignUpScreen(),
          ),
        ),
      );

      expect(authRepository.currentUser, isNull);

      await tester.tap(
        find.widgetWithText(OutlinedButton, 'Continue with Google'),
      );
      await tester.pumpAndSettle();

      expect(authRepository.currentUser, isNotNull);
    });

    testWidgets(
      'cancelling the Google account picker does not show an error message',
      (tester) async {
        final authRepository = FakeAuthRepository()..simulateGoogleCancel = true;
        addTearDown(authRepository.dispose);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [authRepositoryProvider.overrideWithValue(authRepository)],
            child: const MaterialApp(
            localizationsDelegates: localizationWrappers,
            supportedLocales: testSupportedLocales,
            home: SignUpScreen(),
          ),
          ),
        );

        await tester.tap(
          find.widgetWithText(OutlinedButton, 'Continue with Google'),
        );
        await tester.pumpAndSettle();

        expect(authRepository.currentUser, isNull);
        expect(find.text('Sign-in was cancelled.'), findsNothing);
      },
    );

    testWidgets(
      'does not overflow at a large system text scale on a large phone (regression)',
      (tester) async {
        // Same class of bug as SignInScreen's equivalent regression test
        // above — a tester reported the sign-up form cut off at the bottom
        // half of the screen on a 6.7" phone with a large text-size
        // accessibility setting.
        tester.view.physicalSize = const Size(1220, 2712);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.reset);

        final authRepository = FakeAuthRepository();
        addTearDown(authRepository.dispose);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [authRepositoryProvider.overrideWithValue(authRepository)],
            child: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
              child: const MaterialApp(
                localizationsDelegates: localizationWrappers,
                supportedLocales: testSupportedLocales,
                home: SignUpScreen(),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      },
    );
  });
}
