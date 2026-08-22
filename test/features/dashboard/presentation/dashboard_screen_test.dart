import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/authentication/data/auth_providers.dart';
import 'package:vitality/features/authentication/data/fake_auth_repository.dart';
import 'package:vitality/features/blood_pressure/data/app_database.dart';
import 'package:vitality/features/blood_pressure/data/blood_pressure_providers.dart';
import 'package:vitality/features/blood_pressure/data/drift_blood_pressure_repository.dart';
import 'package:vitality/features/dashboard/presentation/dashboard_screen.dart';
import 'package:vitality/features/onboarding/data/fake_user_profile_repository.dart';
import 'package:vitality/features/onboarding/data/user_profile_providers.dart';

// Follows the lesson from Phase 3's blood_pressure widget tests: explicitly
// `await db.close()` at the end of each test body rather than relying on
// implicit teardown, since Drift's stream cleanup otherwise leaves a
// zero-duration Timer pending that flutter_test flags (or hangs on).
void main() {
  testWidgets('shows an empty-state prompt when there are no readings', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final authRepository = FakeAuthRepository();
    addTearDown(authRepository.dispose);
    final profileRepository = FakeUserProfileRepository();
    addTearDown(profileRepository.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          authRepositoryProvider.overrideWithValue(authRepository),
          userProfileRepositoryProvider.overrideWithValue(profileRepository),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );
    await tester.pump();

    expect(find.textContaining("haven't recorded"), findsOneWidget);

    await db.close();
  });

  testWidgets('shows the latest reading and a 7-day summary once data exists', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = DriftBloodPressureRepository(db);
    await repository.addReading(
      systolic: 120,
      diastolic: 80,
      pulse: 70,
      timestamp: DateTime.now(),
    );
    final authRepository = FakeAuthRepository();
    addTearDown(authRepository.dispose);
    final profileRepository = FakeUserProfileRepository();
    addTearDown(profileRepository.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          authRepositoryProvider.overrideWithValue(authRepository),
          userProfileRepositoryProvider.overrideWithValue(profileRepository),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Latest reading'), findsOneWidget);
    expect(find.text('120/80 mmHg'), findsOneWidget);
    expect(find.text('Last 7 days'), findsOneWidget);
    expect(find.textContaining('Average: 120/80 mmHg'), findsOneWidget);

    await db.close();
  });
}
