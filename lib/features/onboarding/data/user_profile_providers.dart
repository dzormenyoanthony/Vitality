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

/// `autoDispose` matters here: without it, a uid's Firestore listener never
/// gets cancelled on sign-out, keeps running in the background until it
/// hits a (now-expected) permission-denied once `request.auth` no longer
/// matches, and Riverpod caches that as a permanent error on this uid's
/// provider instance - so signing back into the *same* account later in the
/// same app session reuses that already-broken instance instead of a fresh
/// subscription, surfacing "Unable to load your profile" for no reason.
/// `autoDispose` tears the listener down as soon as nothing watches it
/// (which happens the moment `authGateProvider` stops watching this uid,
/// right after sign-out), so a later sign-in always starts clean.
final userProfileStreamProvider = StreamProvider.autoDispose.family<UserProfile?, String>(
  (ref, uid) => ref.watch(userProfileRepositoryProvider).watchProfile(uid),
);
