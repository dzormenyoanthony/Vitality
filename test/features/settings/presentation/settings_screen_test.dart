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
import 'package:vitality/features/reminders/data/fake_notification_scheduler.dart';
import 'package:vitality/features/reminders/data/reminder_providers.dart';
import 'package:vitality/features/settings/presentation/settings_screen.dart';

void main() {
  Future<SharedPreferences> mockPrefs() async {
    SharedPreferences.setMockInitialValues({});
    return SharedPreferences.getInstance();
  }

  testWidgets('shows the current email and preferred name', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final scheduler = FakeNotificationScheduler();
    addTearDown(scheduler.dispose);
    final authRepository = FakeAuthRepository();
    addTearDown(authRepository.dispose);
    final profileRepository = FakeUserProfileRepository();
    addTearDown(profileRepository.dispose);
    final user = await authRepository.signUp(email: 'a@b.com', password: 'password123');
    await profileRepository.createProfile(uid: user.uid, displayName: 'Ada');
    final prefs = await mockPrefs();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          notificationSchedulerProvider.overrideWithValue(scheduler),
          authRepositoryProvider.overrideWithValue(authRepository),
          userProfileRepositoryProvider.overrideWithValue(profileRepository),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // The email and name each appear twice now — once in the profile
    // header row, once in their own field below it
    // (design_references/Settings.png).
    expect(find.text('a@b.com'), findsAtLeastNWidgets(1));
    expect(find.text('Ada'), findsAtLeastNWidgets(1));

    await db.close();
  });

  testWidgets('editing and saving the name calls updateDisplayName', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final scheduler = FakeNotificationScheduler();
    addTearDown(scheduler.dispose);
    final authRepository = FakeAuthRepository();
    addTearDown(authRepository.dispose);
    final profileRepository = FakeUserProfileRepository();
    addTearDown(profileRepository.dispose);
    final user = await authRepository.signUp(email: 'a@b.com', password: 'password123');
    await profileRepository.createProfile(uid: user.uid, displayName: 'Ada');
    final prefs = await mockPrefs();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          notificationSchedulerProvider.overrideWithValue(scheduler),
          authRepositoryProvider.overrideWithValue(authRepository),
          userProfileRepositoryProvider.overrideWithValue(profileRepository),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.enterText(find.widgetWithText(TextFormField, 'Ada'), 'Grace');
    await tester.tap(find.byTooltip('Save name'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final profile = await profileRepository.watchProfile(user.uid).first;
    expect(profile!.displayName, 'Grace');

    await db.close();
  });

  testWidgets('selecting a theme option updates the selection', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final scheduler = FakeNotificationScheduler();
    addTearDown(scheduler.dispose);
    final authRepository = FakeAuthRepository();
    addTearDown(authRepository.dispose);
    final profileRepository = FakeUserProfileRepository();
    addTearDown(profileRepository.dispose);
    final user = await authRepository.signUp(email: 'a@b.com', password: 'password123');
    await profileRepository.createProfile(uid: user.uid, displayName: 'Ada');
    final prefs = await mockPrefs();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          notificationSchedulerProvider.overrideWithValue(scheduler),
          authRepositoryProvider.overrideWithValue(authRepository),
          userProfileRepositoryProvider.overrideWithValue(profileRepository),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('Dark'));
    await tester.pump();

    expect(prefs.getString('theme_mode'), 'dark');

    await db.close();
  });

  testWidgets('shows an Export data entry in the Data section', (tester) async {
    // The Data section sits below the fold at the default test surface
    // size now that the profile header/avatar and the redesigned
    // Appearance card push it further down — see the identical note on
    // the delete-account tests below.
    tester.view.physicalSize = const Size(400, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final scheduler = FakeNotificationScheduler();
    addTearDown(scheduler.dispose);
    final authRepository = FakeAuthRepository();
    addTearDown(authRepository.dispose);
    final profileRepository = FakeUserProfileRepository();
    addTearDown(profileRepository.dispose);
    final user = await authRepository.signUp(email: 'a@b.com', password: 'password123');
    await profileRepository.createProfile(uid: user.uid, displayName: 'Ada');
    final prefs = await mockPrefs();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          notificationSchedulerProvider.overrideWithValue(scheduler),
          authRepositoryProvider.overrideWithValue(authRepository),
          userProfileRepositoryProvider.overrideWithValue(profileRepository),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Export data'), findsOneWidget);
    expect(find.text('BP readings (CSV) and saved report files, as a ZIP'), findsOneWidget);

    await db.close();
  });

  testWidgets('cancelling the delete-account dialog keeps the account', (tester) async {
    // The Account section (with "Delete account") sits below the fold at
    // the default test surface size once the Data section is included —
    // a taller surface avoids needing to scroll a list that isn't fully
    // built yet.
    tester.view.physicalSize = const Size(400, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final scheduler = FakeNotificationScheduler();
    addTearDown(scheduler.dispose);
    final authRepository = FakeAuthRepository();
    addTearDown(authRepository.dispose);
    final profileRepository = FakeUserProfileRepository();
    addTearDown(profileRepository.dispose);
    final user = await authRepository.signUp(email: 'a@b.com', password: 'password123');
    await profileRepository.createProfile(uid: user.uid, displayName: 'Ada');
    final prefs = await mockPrefs();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          notificationSchedulerProvider.overrideWithValue(scheduler),
          authRepositoryProvider.overrideWithValue(authRepository),
          userProfileRepositoryProvider.overrideWithValue(profileRepository),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();
    expect(find.text('Delete your account?'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(authRepository.currentUser, isNotNull);

    await db.close();
  });

  testWidgets('confirming the delete-account dialog deletes the account', (tester) async {
    tester.view.physicalSize = const Size(400, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final scheduler = FakeNotificationScheduler();
    addTearDown(scheduler.dispose);
    final authRepository = FakeAuthRepository();
    addTearDown(authRepository.dispose);
    final profileRepository = FakeUserProfileRepository();
    addTearDown(profileRepository.dispose);
    final user = await authRepository.signUp(email: 'a@b.com', password: 'password123');
    await profileRepository.createProfile(uid: user.uid, displayName: 'Ada');
    final prefs = await mockPrefs();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          notificationSchedulerProvider.overrideWithValue(scheduler),
          authRepositoryProvider.overrideWithValue(authRepository),
          userProfileRepositoryProvider.overrideWithValue(profileRepository),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();

    // Fixed-duration pumps instead of pumpAndSettle(): deleteAccount now
    // also reads the live savedReportRepositoryProvider Drift stream, and
    // pumpAndSettle() on a widget that keeps a Drift stream subscription
    // open reproducibly times out in this environment — same reasoning as
    // the `_settle` helper in test/core/router/app_router_flow_test.dart.
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(authRepository.currentUser, isNull);

    await db.close();
  });
}
