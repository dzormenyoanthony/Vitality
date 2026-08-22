import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      () => ref.read(authRepositoryProvider).signIn(email: email, password: password),
    );
  }
}

final signInControllerProvider = AsyncNotifierProvider<SignInController, void>(
  SignInController.new,
);

class SignUpController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> signUp({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signUp(email: email, password: password),
    );
  }
}

final signUpControllerProvider = AsyncNotifierProvider<SignUpController, void>(
  SignUpController.new,
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
