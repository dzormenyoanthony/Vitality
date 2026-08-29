import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/analytics/analytics_providers.dart';
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
      // PROJECT_SPEC.md §26 — onboarding completed (Google/legacy path).
      ref.read(analyticsServiceProvider).logOnboardingCompleted();
    });
  }
}

final onboardingControllerProvider = AsyncNotifierProvider<OnboardingController, void>(
  OnboardingController.new,
);

/// Holds the preferred name collected by the pre-auth onboarding carousel
/// until account creation exists to attach it to. In-memory only (no
/// SharedPreferences): if the app is killed mid-flow, the user simply
/// starts the carousel again on next launch, which is an acceptable
/// restart of an incomplete signup rather than data that needs to survive.
class PendingProfileNameNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String name) => state = name;

  void clear() => state = null;
}

final pendingProfileNameProvider =
    NotifierProvider<PendingProfileNameNotifier, String?>(
      PendingProfileNameNotifier.new,
    );
