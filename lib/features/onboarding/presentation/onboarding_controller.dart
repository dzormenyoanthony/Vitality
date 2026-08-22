import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/user_profile_providers.dart';

/// Saves the preferred name and marks onboarding complete. The router's
/// [authGateProvider] reacts to the resulting profile change and navigates
/// to the dashboard on its own — this controller only tracks the action's
/// loading/error state.
class OnboardingController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> completeOnboarding({
    required String uid,
    required String displayName,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(userProfileRepositoryProvider);
      await repository.createProfile(uid: uid, displayName: displayName);
      await repository.completeOnboarding(uid);
    });
  }
}

final onboardingControllerProvider = AsyncNotifierProvider<OnboardingController, void>(
  OnboardingController.new,
);
