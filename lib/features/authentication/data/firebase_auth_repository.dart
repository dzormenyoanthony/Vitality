import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart' as gsi;

import '../../../core/errors/failure.dart';
import '../../../core/utils/logger.dart';
import 'app_user.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._firebaseAuth);

  final fb.FirebaseAuth _firebaseAuth;

  // `GoogleSignIn.instance.initialize()` must run exactly once before any
  // other call on the singleton; this lazily runs it on first use instead
  // of requiring app-startup wiring elsewhere.
  Future<void>? _googleSignInInit;
  Future<void> _ensureGoogleSignInInitialized() {
    return _googleSignInInit ??= gsi.GoogleSignIn.instance.initialize();
  }

  AppUser _toAppUser(fb.User user) {
    return AppUser(
      uid: user.uid,
      email: user.email,
      emailVerified: user.emailVerified,
    );
  }

  @override
  Stream<AppUser?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map(
      (user) => user == null ? null : _toAppUser(user),
    );
  }

  @override
  AppUser? get currentUser {
    final user = _firebaseAuth.currentUser;
    return user == null ? null : _toAppUser(user);
  }

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _toAppUser(credential.user!);
    } on fb.FirebaseAuthException catch (e) {
      throw mapFirebaseAuthException(e);
    }
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _toAppUser(credential.user!);
    } on fb.FirebaseAuthException catch (e) {
      throw mapFirebaseAuthException(e);
    }
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    try {
      await _ensureGoogleSignInInitialized();
      final account = await gsi.GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw const UnexpectedFailure("Google didn't return a sign-in token.");
      }
      final credential = fb.GoogleAuthProvider.credential(idToken: idToken);
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      return _toAppUser(userCredential.user!);
    } on gsi.GoogleSignInException catch (e) {
      if (e.code == gsi.GoogleSignInExceptionCode.canceled) {
        throw const CancelledFailure();
      }
      AppLogger.error('GoogleSignInException: code=${e.code}', error: e);
      throw const UnexpectedFailure();
    } on fb.FirebaseAuthException catch (e) {
      throw mapFirebaseAuthException(e);
    }
  }

  @override
  Future<void> reauthenticate() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    final isGoogleUser = user.providerData.any(
      (info) => info.providerId == 'google.com',
    );
    // Only Google can be re-verified silently here. Password users fall
    // through: deleteAccount() then surfaces ReauthRequiredFailure and the
    // UI sends them back through a full sign-in.
    if (!isGoogleUser) return;
    try {
      await _ensureGoogleSignInInitialized();
      final account = await gsi.GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw const UnexpectedFailure("Google didn't return a sign-in token.");
      }
      await user.reauthenticateWithCredential(
        fb.GoogleAuthProvider.credential(idToken: idToken),
      );
    } on gsi.GoogleSignInException catch (e) {
      if (e.code == gsi.GoogleSignInExceptionCode.canceled) {
        throw const CancelledFailure();
      }
      AppLogger.error('Google re-auth failed: code=${e.code}', error: e);
      throw const UnexpectedFailure();
    } on fb.FirebaseAuthException catch (e) {
      throw mapFirebaseAuthException(e);
    }
  }

  @override
  Future<void> signOut() async {
    // Clear the Google Sign-In session too, otherwise the plugin keeps the
    // account authorized and the next "Continue with Google" can silently
    // reuse stale state. No-op / harmless for a non-Google user.
    try {
      await _ensureGoogleSignInInitialized();
      await gsi.GoogleSignIn.instance.signOut();
    } catch (e) {
      AppLogger.error('Google sign-out skipped', error: e);
    }
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on fb.FirebaseAuthException catch (e) {
      throw mapFirebaseAuthException(e);
    }
  }

  @override
  Future<void> deleteAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const UnexpectedFailure('No signed-in user to delete.');
    }
    final isGoogleUser = user.providerData.any(
      (info) => info.providerId == 'google.com',
    );
    try {
      await user.delete();
    } on fb.FirebaseAuthException catch (e) {
      throw mapFirebaseAuthException(e);
    }
    if (isGoogleUser) {
      // Revoke the Google grant so signing in again with the same account
      // starts a fresh consent instead of reusing the deleted user's
      // authorization. Best-effort: the account is already gone.
      try {
        await _ensureGoogleSignInInitialized();
        await gsi.GoogleSignIn.instance.disconnect();
      } catch (e) {
        AppLogger.error('Google disconnect after deletion skipped', error: e);
      }
    }
  }
}

/// Maps Firebase's error codes to understandable, non-technical messages
/// (CLAUDE.md §12: never expose raw exceptions to users). A top-level pure
/// function so it's directly unit-testable without a live Firebase project.
///
/// Logs the raw error code first — the code itself carries no sensitive
/// data, and without this an unmapped code is otherwise unrecoverable to
/// diagnose (only the generic [UnexpectedFailure] message ever reaches the
/// user or any log).
Failure mapFirebaseAuthException(fb.FirebaseAuthException e) {
  AppLogger.error('FirebaseAuthException: code=${e.code}', error: e);
  switch (e.code) {
    case 'email-already-in-use':
      return const ValidationFailure(
        'An account already exists for this email address.',
      );
    case 'invalid-email':
      return const ValidationFailure('Enter a valid email address.');
    case 'weak-password':
      return const ValidationFailure(
        'Choose a stronger password (at least 6 characters).',
      );
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return const ValidationFailure('Incorrect email or password.');
    case 'user-disabled':
      return const ValidationFailure('This account has been disabled.');
    case 'too-many-requests':
      return const ValidationFailure(
        'Too many attempts. Please try again later.',
      );
    case 'network-request-failed':
      return const NetworkFailure();
    case 'requires-recent-login':
      return const ReauthRequiredFailure();
    case 'user-mismatch':
      return const ValidationFailure(
        'That is a different account than the one you are signed in with.',
      );
    default:
      return const UnexpectedFailure();
  }
}
