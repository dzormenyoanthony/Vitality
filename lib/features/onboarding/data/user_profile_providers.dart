import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firestore_user_profile_repository.dart';
import 'user_profile.dart';
import 'user_profile_repository.dart';

/// Concrete [UserProfileRepository] used by the running app. Tests override
/// this with a [FakeUserProfileRepository] instead of touching Firestore.
final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return FirestoreUserProfileRepository(FirebaseFirestore.instance);
});

final userProfileStreamProvider = StreamProvider.family<UserProfile?, String>(
  (ref, uid) => ref.watch(userProfileRepositoryProvider).watchProfile(uid),
);
