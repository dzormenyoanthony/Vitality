import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/core/router/auth_gate_provider.dart';
import 'package:vitality/features/authentication/data/auth_providers.dart';
import 'package:vitality/features/authentication/data/fake_auth_repository.dart';
import 'package:vitality/features/onboarding/data/fake_user_profile_repository.dart';
import 'package:vitality/features/onboarding/data/user_profile_providers.dart';

/// Polls until [condition] is true rather than guessing a fixed number of
/// microtask/event-loop turns, which is fragile once multiple chained
/// streams (auth state -> profile state -> gate state) are involved.
Future<void> _waitUntil(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 2),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('Condition not met within $timeout');
    }
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}

void main() {
  late FakeAuthRepository authRepository;
  late FakeUserProfileRepository profileRepository;
  late ProviderContainer container;

  setUp(() {
    authRepository = FakeAuthRepository();
    profileRepository = FakeUserProfileRepository();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        userProfileRepositoryProvider.overrideWithValue(profileRepository),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(authRepository.dispose);
    addTearDown(profileRepository.dispose);
  });

  test('resolves to unauthenticated when no user is signed in', () async {
    container.listen(authGateProvider, (_, _) {});
    await _waitUntil(() => container.read(authGateProvider) is AuthGateUnauthenticated);

    expect(container.read(authGateProvider), isA<AuthGateUnauthenticated>());
  });

  test('resolves to needsOnboarding right after sign-up', () async {
    container.listen(authGateProvider, (_, _) {});
    await authRepository.signUp(email: 'user@example.com', password: 'password123');
    await _waitUntil(() => container.read(authGateProvider) is AuthGateNeedsOnboarding);

    expect(container.read(authGateProvider), isA<AuthGateNeedsOnboarding>());
  });

  test('resolves to ready once onboarding is completed', () async {
    container.listen(authGateProvider, (_, _) {});
    final user = await authRepository.signUp(
      email: 'user@example.com',
      password: 'password123',
    );
    await profileRepository.createProfile(uid: user.uid, displayName: 'Alex');
    await profileRepository.completeOnboarding(user.uid);
    await _waitUntil(() => container.read(authGateProvider) is AuthGateReady);

    final state = container.read(authGateProvider);
    expect(state, isA<AuthGateReady>());
    expect((state as AuthGateReady).displayName, 'Alex');
  });

  test('resolves to a distinct error state when the profile stream fails, '
      'never staying stuck on loading', () async {
    container.listen(authGateProvider, (_, _) {});
    final user = await authRepository.signUp(
      email: 'user@example.com',
      password: 'password123',
    );
    await _waitUntil(() => container.read(authGateProvider) is AuthGateNeedsOnboarding);
    profileRepository.simulateProfileError(user.uid);
    await _waitUntil(() => container.read(authGateProvider) is AuthGateError);

    final state = container.read(authGateProvider);
    expect(state, isA<AuthGateError>());
    expect((state as AuthGateError).uid, user.uid);
    expect(state.message, isNotEmpty);
  });

  test('resolves back to unauthenticated after sign-out', () async {
    container.listen(authGateProvider, (_, _) {});
    final user = await authRepository.signUp(
      email: 'user@example.com',
      password: 'password123',
    );
    await profileRepository.createProfile(uid: user.uid, displayName: 'Alex');
    await profileRepository.completeOnboarding(user.uid);
    await _waitUntil(() => container.read(authGateProvider) is AuthGateReady);

    await authRepository.signOut();
    await _waitUntil(() => container.read(authGateProvider) is AuthGateUnauthenticated);

    expect(container.read(authGateProvider), isA<AuthGateUnauthenticated>());
  });
}
