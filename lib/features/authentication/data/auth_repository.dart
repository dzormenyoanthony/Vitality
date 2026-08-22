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

  Future<void> signOut();

  Future<void> sendPasswordResetEmail(String email);

  /// Permanently deletes the current user's account
  /// (PROJECT_SPEC.md §20, §24).
  Future<void> deleteAccount();
}
