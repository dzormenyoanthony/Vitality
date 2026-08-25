import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vitality/core/services/shared_preferences_provider.dart';
import 'package:vitality/features/authentication/data/auth_providers.dart';
import 'package:vitality/features/authentication/data/fake_auth_repository.dart';
import 'package:vitality/features/blood_pressure/data/app_database.dart';
import 'package:vitality/features/blood_pressure/data/blood_pressure_providers.dart';
import 'package:vitality/features/onboarding/data/fake_user_profile_repository.dart';
import 'package:vitality/features/onboarding/data/user_profile_providers.dart';
import 'package:vitality/main.dart';

/// A bounded alternative to `pumpAndSettle()`. A focused `TextFormField`'s
/// blinking-cursor timer reschedules a frame forever, so `pumpAndSettle()`
/// never returns once a field has been typed into — this unfocuses first,
/// then pumps a fixed duration, comfortably covering the default page
/// transition, so redirects and navigation settle deterministically.
Future<void> _settle(WidgetTester tester) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
}

// This test covers sign-up through onboarding completion only. It
// deliberately stops short of fully settling onto the Dashboard: Dashboard
// watches a live Drift native stream (readingsStreamProvider), and fully
// settling a widget that watches a Drift stream while mounted under
// go_router reproducibly hangs flutter_test in this environment — verified
// twice independently, including with the correct appDatabaseProvider
// override in place, so it isn't a missing-override issue. The auth-state
// -> route decision itself (including the transition into the "ready" /
// dashboard-bound state) is covered by
// test/core/router/auth_gate_provider_test.dart; Dashboard's own rendering
// is covered in isolation by
// test/features/dashboard/presentation/dashboard_screen_test.dart; the
// full on-device flow (including sign-out from the dashboard) has been
// manually verified together with the user.
void main() {
  testWidgets(
    'sign-up -> onboarding walks through every route redirect up to completion',
    (tester) async {
      final authRepository = FakeAuthRepository();
      final profileRepository = FakeUserProfileRepository();
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(authRepository.dispose);
      addTearDown(profileRepository.dispose);
      addTearDown(db.close);
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(authRepository),
            userProfileRepositoryProvider.overrideWithValue(profileRepository),
            appDatabaseProvider.overrideWithValue(db),
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const VitalyApp(),
        ),
      );
      await _settle(tester);

      // Unauthenticated -> sign-in.
      expect(find.text('Welcome back'), findsOneWidget);

      await tester.tap(
        find.widgetWithText(TextButton, "Don't have an account? Create one"),
      );
      await _settle(tester);
      expect(find.text('Start your blood pressure story'), findsOneWidget);

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
        'password123',
      );
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.pump();
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tester.ensureVisible(
        find.widgetWithText(FilledButton, 'Create account'),
      );
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
      await _settle(tester);

      // Authenticated but not onboarded -> onboarding carousel, step 1.
      expect(find.text('Two numbers, five seconds.'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await _settle(tester);
      expect(find.text('Watch the line, not the number.'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await _settle(tester);
      expect(find.text('Reminders that fit your day.'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Get started'));
      await _settle(tester);
      expect(find.text('WHAT SHOULD WE CALL YOU?'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'Alex');
      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      // Deliberately minimal, bounded pumping here — just enough for the
      // save's Future to resolve, not enough to carry the subsequent
      // auth-gate-driven redirect all the way to a fully settled Dashboard
      // (see the file-level comment above).
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      final user = authRepository.currentUser;
      expect(user, isNotNull);
      final profile = await profileRepository.watchProfile(user!.uid).first;
      expect(profile?.onboardingCompleted, isTrue);
      expect(profile?.displayName, 'Alex');

      await db.close();
    },
  );
}
