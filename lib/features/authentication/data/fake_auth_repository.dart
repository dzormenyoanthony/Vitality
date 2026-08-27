import 'dart:async';

import '../../../core/errors/failure.dart';
import 'app_user.dart';
import 'auth_repository.dart';

/// In-memory [AuthRepository] used in tests (and available for local
/// development before Firebase config is wired up). Mirrors the real
/// implementation's error-mapping behavior without any network dependency.
class FakeAuthRepository implements AuthRepository {
  final _changes = StreamController<AppUser?>.broadcast();
  final Map<String, String> _accounts = {};
  AppUser? _currentUser;
  int _uidCounter = 0;

  /// Test-only: makes the next [signInWithGoogle] call behave as if the
  /// user dismissed the account picker, instead of succeeding.
  bool simulateGoogleCancel = false;

  @override
  Stream<AppUser?> authStateChanges() async* {
    // Mirrors Firebase Auth's real behavior: emit the current state
    // immediately on subscription, then forward every subsequent change.
    yield _currentUser;
    yield* _changes.stream;
  }

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
  }) async {
    if (_accounts.containsKey(email)) {
      throw const ValidationFailure(
        'An account already exists for this email address.',
      );
    }
    _accounts[email] = password;
    final user = AppUser(
      uid: 'fake-uid-${_uidCounter++}',
      email: email,
      emailVerified: false,
    );
    _currentUser = user;
    _changes.add(user);
    return user;
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    if (_accounts[email] != password) {
      throw const ValidationFailure('Incorrect email or password.');
    }
    final user = AppUser(
      uid: 'fake-uid-${_accounts.keys.toList().indexOf(email)}',
      email: email,
      emailVerified: false,
    );
    _currentUser = user;
    _changes.add(user);
    return user;
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    if (simulateGoogleCancel) {
      throw const CancelledFailure();
    }
    const email = 'fake-google-user@example.com';
    _accounts.putIfAbsent(email, () => '');
    final user = AppUser(
      uid: 'fake-google-uid-${_uidCounter++}',
      email: email,
      emailVerified: true,
    );
    _currentUser = user;
    _changes.add(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _changes.add(null);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    if (!_accounts.containsKey(email)) {
      throw const ValidationFailure('No account found for this email.');
    }
  }

  @override
  Future<void> deleteAccount() async {
    final user = _currentUser;
    if (user == null) {
      throw const UnexpectedFailure('No signed-in user to delete.');
    }
    _accounts.remove(user.email);
    _currentUser = null;
    _changes.add(null);
  }

  void dispose() => _changes.close();
}
