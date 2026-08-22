import 'user_profile.dart';

/// Abstraction over the profile/onboarding-status backend (Firestore per
/// PROJECT_SPEC.md §21).
abstract interface class UserProfileRepository {
  /// Emits `null` while no profile document exists yet for [uid].
  Stream<UserProfile?> watchProfile(String uid);

  Future<void> createProfile({required String uid, required String displayName});

  Future<void> completeOnboarding(String uid);

  Future<void> updateDisplayName(String uid, String displayName);

  Future<void> deleteProfile(String uid);
}
