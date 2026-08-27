import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vitality/core/router/splash_min_duration_provider.dart';
import 'package:vitality/core/services/shared_preferences_provider.dart';
import 'package:vitality/features/authentication/data/auth_providers.dart';
import 'package:vitality/features/authentication/data/fake_auth_repository.dart';
import 'package:vitality/features/blood_pressure/data/app_database.dart';
import 'package:vitality/features/blood_pressure/data/blood_pressure_providers.dart';
import 'package:vitality/features/onboarding/data/fake_user_profile_repository.dart';
import 'package:vitality/features/onboarding/data/user_profile.dart';
import 'package:vitality/features/onboarding/data/user_profile_providers.dart';
import 'package:vitality/features/onboarding/data/user_profile_repository.dart';
import 'package:vitality/main.dart';

/// A bounded alternative to `pumpAndSettle()`. A focused `TextFormField`'s
/// blinking-cursor timer reschedules a frame forever, so `pumpAndSettle()`
/// never returns once a field has been typed into — this unfocuses first,
/// then pumps a fixed duration, comfortably covering the default page
/// transition, so redirects and navigation settle deterministically.
///
/// Must clear [splashMinDuration] (the router keeps the app on Splash until
/// that elapses, regardless of auth/onboarding state) on top of the normal
/// transition time, since the very first call is what carries the app past
/// the initial Splash screen.
Future<void> _settle(WidgetTester tester) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pump();
  await tester.pump(splashMinDuration);
  await tester.pump(const Duration(milliseconds: 500));
}

// This test covers the brand-new-user path: onboarding carousel (pre-auth)
// through account creation. It deliberately stops short of fully settling
// onto the Dashboard: Dashboard watches a live Drift native stream
// (readingsStreamProvider), and fully settling a widget that watches a
// Drift stream while mounted under go_router reproducibly hangs
// flutter_test in this environment — verified twice independently,
// including with the correct appDatabaseProvider override in place, so it
// isn't a missing-override issue. The auth-state -> route decision itself
// (including the transition into the "ready" / dashboard-bound state) is
// covered by test/core/router/auth_gate_provider_test.dart; Dashboard's own
// rendering is covered in isolation by
// test/features/dashboard/presentation/dashboard_screen_test.dart; the full
// on-device flow (including sign-out from the dashboard) has been manually
// verified together with the user.
void main() {
  testWidgets(
    'brand-new user: onboarding carousel -> create account walks through every route redirect up to completion',
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

      // Unauthenticated, onboarding never seen on this device -> the intro
      // carousel, not Sign In.
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
      await _settle(tester);

      // Name collected pre-auth -> handed off to Create Account.
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
      // Deliberately minimal, bounded pumping here — just enough for
      // sign-up plus the chained profile-creation Future to resolve, not
      // enough to carry the subsequent auth-gate-driven redirect all the
      // way to a fully settled Dashboard (see the file-level comment above).
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final user = authRepository.currentUser;
      expect(user, isNotNull);
      final profile = await profileRepository.watchProfile(user!.uid).first;
      expect(profile?.onboardingCompleted, isTrue);
      expect(profile?.displayName, 'Alex');

      // The device-local "don't show onboarding again" flag is persisted
      // as a side effect of reaching AuthGateReady (main.dart's
      // `_handleAuthGateChange`), which depends on the router's redirect
      // listener finishing its own propagation on top of the profile
      // write above — bounded pumping alone is unreliable for that full
      // chain in this environment (see this file's header comment), so
      // that specific persistence behavior is covered on its own, without
      // the router/widget tree, by
      // test/features/onboarding/data/onboarding_intro_provider_test.dart.

      await db.close();
    },
  );

  testWidgets(
    'existing user not signed in on a device that has already onboarded -> Sign In, not the carousel',
    (tester) async {
      final authRepository = FakeAuthRepository();
      final profileRepository = FakeUserProfileRepository();
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(authRepository.dispose);
      addTearDown(profileRepository.dispose);
      addTearDown(db.close);
      SharedPreferences.setMockInitialValues({'onboarding_intro_seen': true});
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

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Two numbers, five seconds.'), findsNothing);

      await db.close();
    },
  );

  testWidgets(
    'existing user signs in -> the profile stream\'s transient Loading tick '
    'never bounces the app back to Splash',
    (tester) async {
      final authRepository = FakeAuthRepository();
      final profileRepository = FakeUserProfileRepository();
      // A real Firestore listener takes a beat to deliver its first
      // snapshot; FakeUserProfileRepository resolves synchronously, which
      // would make this test pass whether or not the router actually
      // handles AuthGateLoading correctly. This delay keeps the gate
      // observably in AuthGateLoading for a few pumps after sign-in, the
      // same way a real profile fetch would.
      final delayedProfileRepository = _DelayedProfileRepository(profileRepository);
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(authRepository.dispose);
      addTearDown(profileRepository.dispose);
      addTearDown(db.close);

      final user = await authRepository.signUp(
        email: 'existing@example.com',
        password: 'password123',
      );
      await profileRepository.createProfile(uid: user.uid, displayName: 'Alex');
      await profileRepository.completeOnboarding(user.uid);
      await authRepository.signOut();

      SharedPreferences.setMockInitialValues({'onboarding_intro_seen': true});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(authRepository),
            userProfileRepositoryProvider.overrideWithValue(delayedProfileRepository),
            appDatabaseProvider.overrideWithValue(db),
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const VitalyApp(),
        ),
      );
      await _settle(tester);
      expect(find.text('Welcome back'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'EMAIL'),
        'existing@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'PASSWORD'),
        'password123',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();

      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      // Splash's copy must never render on ANY frame while the (deliberately
      // slowed) profile stream resolves - checked at several checkpoints
      // spanning that delay, not just after settling, since a single-frame
      // flash could otherwise come and go unnoticed.
      for (final step in [
        Duration.zero,
        const Duration(milliseconds: 10),
        const Duration(milliseconds: 10),
        const Duration(milliseconds: 10),
        const Duration(milliseconds: 200),
      ]) {
        await tester.pump(step);
        expect(find.text('NOT A MEDICAL DEVICE'), findsNothing);
      }

      // Confirms the tap actually drove SignInController.signIn() to
      // completion (not a hollow pass from a missed tap or a validation
      // error that never left the Sign In screen).
      expect(authRepository.currentUser?.uid, user.uid);

      await db.close();
    },
  );
}

/// Wraps a [UserProfileRepository] so its `watchProfile` stream takes a
/// beat before its first emission, mimicking a real Firestore listener's
/// latency (see the test above for why this matters).
class _DelayedProfileRepository implements UserProfileRepository {
  _DelayedProfileRepository(this._inner);

  final UserProfileRepository _inner;

  @override
  Stream<UserProfile?> watchProfile(String uid) async* {
    await Future<void>.delayed(const Duration(milliseconds: 30));
    yield* _inner.watchProfile(uid);
  }

  @override
  Future<void> createProfile({required String uid, required String displayName}) =>
      _inner.createProfile(uid: uid, displayName: displayName);

  @override
  Future<void> completeOnboarding(String uid) => _inner.completeOnboarding(uid);

  @override
  Future<void> updateDisplayName(String uid, String displayName) =>
      _inner.updateDisplayName(uid, displayName);

  @override
  Future<void> deleteProfile(String uid) => _inner.deleteProfile(uid);
}
