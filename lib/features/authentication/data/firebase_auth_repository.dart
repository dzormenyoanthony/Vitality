import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../../core/errors/failure.dart';
import '../../../core/utils/logger.dart';
import 'app_user.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._firebaseAuth);

  final fb.FirebaseAuth _firebaseAuth;

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
  Future<void> signOut() => _firebaseAuth.signOut();

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
    try {
      await user.delete();
    } on fb.FirebaseAuthException catch (e) {
      throw mapFirebaseAuthException(e);
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
      return const ValidationFailure(
        'Please sign in again to complete this action.',
      );
    default:
      return const UnexpectedFailure();
  }
}
