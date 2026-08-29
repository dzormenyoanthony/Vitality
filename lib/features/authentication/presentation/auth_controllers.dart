import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/analytics/analytics_providers.dart';
import '../../../core/errors/failure.dart';
import '../../onboarding/data/user_profile_providers.dart';
import '../../onboarding/presentation/onboarding_controller.dart';
import '../data/auth_providers.dart';

/// One [AsyncNotifier] per auth form action. The router's [authGateProvider]
/// (driven by `authStateChanges()`) handles navigation on success, so these
/// controllers only need to track loading/error for their own screen.
class SignInController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password),
    );
  }
}

final signInControllerProvider = AsyncNotifierProvider<SignInController, void>(
  SignInController.new,
);

class SignUpController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// If the pre-auth onboarding carousel already collected a preferred
  /// name (see [pendingProfileNameProvider]), the profile is created with
  /// it immediately so the new user lands on a fully-onboarded Dashboard.
  /// Otherwise (account creation reached without going through onboarding
  /// first — e.g. via Sign In's "Create an account" link) the profile is
  /// left to be created by the [AuthGateNeedsOnboarding] fallback screen.
  Future<void> signUp({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref
          .read(authRepositoryProvider)
          .signUp(email: email, password: password);

      final pendingName = ref.read(pendingProfileNameProvider);
      if (pendingName != null) {
        final profileRepository = ref.read(userProfileRepositoryProvider);
        await profileRepository.createProfile(
          uid: user.uid,
          displayName: pendingName,
        );
        await profileRepository.completeOnboarding(user.uid);
        ref.read(pendingProfileNameProvider.notifier).clear();
        // PROJECT_SPEC.md §26 — onboarding completed (pre-auth carousel path).
        ref.read(analyticsServiceProvider).logOnboardingCompleted();
      }
    });
  }
}

final signUpControllerProvider = AsyncNotifierProvider<SignUpController, void>(
  SignUpController.new,
);

class GoogleSignInController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signInWithGoogle(),
    );
    // The user simply backed out of the account picker - not a real error,
    // so reset to idle instead of showing a false "something went wrong"
    // message (CLAUDE.md §12).
    state = switch (result) {
      AsyncError(:final error) when error is CancelledFailure => const AsyncData(null),
      _ => result,
    };
  }
}

final googleSignInControllerProvider =
    AsyncNotifierProvider<GoogleSignInController, void>(
      GoogleSignInController.new,
    );

class ForgotPasswordController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> sendResetEmail(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).sendPasswordResetEmail(email),
    );
  }
}

final forgotPasswordControllerProvider =
    AsyncNotifierProvider<ForgotPasswordController, void>(
      ForgotPasswordController.new,
    );
