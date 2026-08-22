import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/errors/failure.dart';
import '../../../core/utils/logger.dart';
import 'user_profile.dart';
import 'user_profile_repository.dart';

class FirestoreUserProfileRepository implements UserProfileRepository {
  FirestoreUserProfileRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  @override
  Stream<UserProfile?> watchProfile(String uid) {
    return _users
        .doc(uid)
        .snapshots()
        .map((snapshot) {
          final data = snapshot.data();
          if (data == null) return null;
          return UserProfile(
            displayName: data['displayName'] as String? ?? '',
            onboardingCompleted: data['onboardingCompleted'] as bool? ?? false,
          );
        })
        .handleError((Object error, StackTrace stackTrace) {
          // A stream error here (e.g. denied security rules) must not be
          // silently swallowed or retried forever by the auth gate — log
          // the technical cause and surface a safe message (CLAUDE.md §12).
          AppLogger.error(
            'Firestore watchProfile error for uid=$uid',
            error: error,
            stackTrace: stackTrace,
          );
          throw const ServerFailure(
            'Unable to load your profile. Please try again.',
          );
        });
  }

  @override
  Future<void> createProfile({
    required String uid,
    required String displayName,
  }) {
    return _users.doc(uid).set({
      'displayName': displayName,
      'onboardingCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> completeOnboarding(String uid) {
    return _users.doc(uid).set({
      'onboardingCompleted': true,
    }, SetOptions(merge: true));
  }

  @override
  Future<void> updateDisplayName(String uid, String displayName) {
    return _users.doc(uid).set({
      'displayName': displayName,
    }, SetOptions(merge: true));
  }

  @override
  Future<void> deleteProfile(String uid) {
    return _users.doc(uid).delete();
  }
}
