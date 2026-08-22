import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_user.dart';
import 'auth_repository.dart';
import 'firebase_auth_repository.dart';

/// Concrete [AuthRepository] used by the running app. Tests override this
/// provider with a [FakeAuthRepository] instead of touching Firebase.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository(fb.FirebaseAuth.instance);
});

final authStateChangesProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});
