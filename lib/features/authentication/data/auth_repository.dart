import 'app_user.dart';

/// Abstraction over the authentication provider (Firebase Auth per
/// PROJECT_SPEC.md §20).
///
/// The presentation layer depends only on this interface, never on
/// `firebase_auth` types directly, so the provider can be swapped and so
/// tests can run against [FakeAuthRepository] without a live connection.
abstract interface class AuthRepository {
  /// Emits the current user on every sign-in/sign-out, and `null` when
  /// signed out. Used to drive the router's auth gate.
  Stream<AppUser?> authStateChanges();

  AppUser? get currentUser;

  Future<AppUser> signUp({required String email, required String password});

  Future<AppUser> signIn({required String email, required String password});

  /// Signs in (creating the account on first use) via Google OAuth — one of
  /// the "secure sign-in" methods PROJECT_SPEC.md §20 allows. Requires
  /// Google Sign-In to be enabled as a provider in the Firebase console
  /// (with SHA-1/SHA-256 fingerprints registered for Android) before it will
  /// work at runtime; the code path itself doesn't depend on that being
  /// done yet.
  Future<AppUser> signInWithGoogle();

  Future<void> signOut();

  Future<void> sendPasswordResetEmail(String email);

  /// Re-verifies the signed-in user's identity so a following
  /// [deleteAccount] isn't rejected for a stale session. Call this first,
  /// before destroying any of the user's data.
  ///
  /// For a Google user this re-runs the Google flow (may show the account
  /// picker). For a provider that can't be re-verified without extra input
  /// (email/password), it does nothing here and lets [deleteAccount]
  /// surface [ReauthRequiredFailure] instead. Throws [CancelledFailure] if
  /// the user backs out.
  Future<void> reauthenticate();

  /// Permanently deletes the current user's account
  /// (PROJECT_SPEC.md §20, §24). Call [reauthenticate] first — Firebase
  /// rejects this with a [ReauthRequiredFailure] if the sign-in is old.
  Future<void> deleteAccount();
}
