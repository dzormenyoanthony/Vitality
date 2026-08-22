import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/authentication/data/auth_providers.dart';
import '../../features/onboarding/data/user_profile_providers.dart';
import '../errors/failure.dart';

/// The single source of truth the router's `redirect:` reads to decide
/// where the user should land (PROJECT_SPEC.md §30: Authentication →
/// Onboarding → Main application).
sealed class AuthGateState {
  const AuthGateState();
}

class AuthGateLoading extends AuthGateState {
  const AuthGateLoading();
}

class AuthGateUnauthenticated extends AuthGateState {
  const AuthGateUnauthenticated();
}

class AuthGateNeedsOnboarding extends AuthGateState {
  const AuthGateNeedsOnboarding(this.uid);
  final String uid;

  @override
  bool operator ==(Object other) =>
      other is AuthGateNeedsOnboarding && other.uid == uid;

  @override
  int get hashCode => uid.hashCode;
}

class AuthGateReady extends AuthGateState {
  const AuthGateReady(this.uid, this.displayName);
  final String uid;
  final String displayName;

  @override
  bool operator ==(Object other) =>
      other is AuthGateReady && other.uid == uid && other.displayName == displayName;

  @override
  int get hashCode => Object.hash(uid, displayName);
}

/// The user is authenticated but their profile couldn't be loaded (e.g. a
/// Firestore permission or connectivity failure). Distinct from
/// [AuthGateLoading] so a broken/misconfigured backend surfaces as a real,
/// retryable error instead of hanging on the splash screen forever
/// (CLAUDE.md §24: every important screen needs an explicit error state).
class AuthGateError extends AuthGateState {
  const AuthGateError(this.uid, this.message);
  final String uid;
  final String message;

  @override
  bool operator ==(Object other) =>
      other is AuthGateError && other.uid == uid && other.message == message;

  @override
  int get hashCode => Object.hash(uid, message);
}

final authGateProvider = Provider<AuthGateState>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  // Riverpod's StreamProvider automatically retries a failed stream, which
  // puts it back into `isLoading` while a retry is pending — `hasError` is
  // still true throughout. Checking `.when()` alone would silently treat
  // that retry-loading state as plain loading and hide the error again, so
  // `hasError` must be checked first, before `.when()`.
  if (authState.hasError) return const AuthGateUnauthenticated();

  return authState.when(
    loading: () => const AuthGateLoading(),
    error: (_, _) => const AuthGateUnauthenticated(),
    data: (user) {
      if (user == null) return const AuthGateUnauthenticated();

      final profileState = ref.watch(userProfileStreamProvider(user.uid));
      if (profileState.hasError) {
        return AuthGateError(user.uid, friendlyMessage(profileState.error!));
      }

      return profileState.when(
        loading: () => const AuthGateLoading(),
        error: (error, _) => AuthGateError(user.uid, friendlyMessage(error)),
        data: (profile) {
          if (profile == null || !profile.onboardingCompleted) {
            return AuthGateNeedsOnboarding(user.uid);
          }
          return AuthGateReady(user.uid, profile.displayName);
        },
      );
    },
  );
});
