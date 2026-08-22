import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/authentication/data/auth_providers.dart';
import 'package:vitality/features/authentication/data/fake_auth_repository.dart';
import 'package:vitality/features/onboarding/data/fake_user_profile_repository.dart';
import 'package:vitality/features/onboarding/data/user_profile_providers.dart';
import 'package:vitality/main.dart';

void main() {
  testWidgets('VitalyApp launches and renders the initial route', (
    WidgetTester tester,
  ) async {
    final authRepository = FakeAuthRepository();
    final profileRepository = FakeUserProfileRepository();
    addTearDown(authRepository.dispose);
    addTearDown(profileRepository.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          userProfileRepositoryProvider.overrideWithValue(profileRepository),
        ],
        child: const VitalyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Unauthenticated by default, so the router redirects to sign-in.
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
