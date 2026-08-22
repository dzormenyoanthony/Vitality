import 'dart:async';

import '../../../core/errors/failure.dart';
import 'user_profile.dart';
import 'user_profile_repository.dart';

/// In-memory [UserProfileRepository] used in tests.
class FakeUserProfileRepository implements UserProfileRepository {
  final Map<String, UserProfile> _profiles = {};
  final Set<String> _erroringUids = {};
  final _changes = StreamController<String>.broadcast();

  @override
  Stream<UserProfile?> watchProfile(String uid) async* {
    if (_erroringUids.contains(uid)) {
      throw const ServerFailure('Unable to load your profile. Please try again.');
    }
    yield _profiles[uid];
    await for (final changedUid in _changes.stream) {
      if (changedUid != uid) continue;
      if (_erroringUids.contains(uid)) {
        throw const ServerFailure('Unable to load your profile. Please try again.');
      }
      yield _profiles[uid];
    }
  }

  @override
  Future<void> createProfile({
    required String uid,
    required String displayName,
  }) async {
    _profiles[uid] = UserProfile(
      displayName: displayName,
      onboardingCompleted: false,
    );
    _changes.add(uid);
  }

  @override
  Future<void> completeOnboarding(String uid) async {
    final existing = _profiles[uid];
    if (existing == null) return;
    _profiles[uid] = UserProfile(
      displayName: existing.displayName,
      onboardingCompleted: true,
    );
    _changes.add(uid);
  }

  @override
  Future<void> updateDisplayName(String uid, String displayName) async {
    final existing = _profiles[uid];
    if (existing == null) return;
    _profiles[uid] = UserProfile(
      displayName: displayName,
      onboardingCompleted: existing.onboardingCompleted,
    );
    _changes.add(uid);
  }

  @override
  Future<void> deleteProfile(String uid) async {
    _profiles.remove(uid);
    _changes.add(uid);
  }

  /// Test-only: makes subsequent (or already-active) [watchProfile] calls
  /// for [uid] emit an error, simulating e.g. a denied Firestore read.
  void simulateProfileError(String uid) {
    _erroringUids.add(uid);
    _changes.add(uid);
  }

  void dispose() => _changes.close();
}
