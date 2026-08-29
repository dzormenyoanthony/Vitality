import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vitality/core/analytics/analytics_providers.dart';
import 'package:vitality/core/services/shared_preferences_provider.dart';
import 'package:vitality/features/authentication/data/auth_providers.dart';
import 'package:vitality/features/authentication/data/fake_auth_repository.dart';
import 'package:vitality/features/onboarding/data/fake_user_profile_repository.dart';
import 'package:vitality/features/onboarding/data/user_profile_providers.dart';
import 'package:vitality/main.dart';

import 'support/fake_analytics_service.dart';

void main() {
  testWidgets('VitalyApp launches, renders the initial route, and logs app_opened', (
    WidgetTester tester,
  ) async {
    final authRepository = FakeAuthRepository();
    final profileRepository = FakeUserProfileRepository();
    final analytics = FakeAnalyticsService();
    addTearDown(authRepository.dispose);
    addTearDown(profileRepository.dispose);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          userProfileRepositoryProvider.overrideWithValue(profileRepository),
          sharedPreferencesProvider.overrideWithValue(prefs),
          analyticsServiceProvider.overrideWithValue(analytics),
        ],
        child: const VitalyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Unauthenticated and never onboarded on this device by default, so
    // the router redirects to the intro carousel, not sign-in.
    expect(find.text('Two numbers, five seconds.'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
    // PROJECT_SPEC.md §26 "app opened".
    expect(analytics.events, contains('app_opened'));
  });
}
