import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/onboarding/data/user_profile.dart';
import 'package:vitality/features/onboarding/data/user_profile_providers.dart';
import 'package:vitality/features/onboarding/data/user_profile_repository.dart';

/// Counts how many times `watchProfile` is actually called, so a test can
/// tell a genuinely fresh subscription apart from a cached one.
class _CountingProfileRepository implements UserProfileRepository {
  int watchCallCount = 0;

  @override
  Stream<UserProfile?> watchProfile(String uid) {
    watchCallCount++;
    return Stream.value(
      const UserProfile(displayName: 'Alex', onboardingCompleted: true),
    );
  }

  @override
  Future<void> createProfile({required String uid, required String displayName}) async {}

  @override
  Future<void> completeOnboarding(String uid) async {}

  @override
  Future<void> updateDisplayName(String uid, String displayName) async {}

  @override
  Future<void> deleteProfile(String uid) async {}
}

void main() {
  test(
    'userProfileStreamProvider creates a fresh subscription each time it is '
    'watched again after being fully unwatched, instead of reusing a stale '
    '(possibly errored) instance left over from an earlier sign-in this '
    'session',
    () async {
      final repository = _CountingProfileRepository();
      final container = ProviderContainer(
        overrides: [userProfileRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      const uid = 'uid-1';

      final firstSubscription = container.listen(
        userProfileStreamProvider(uid),
        (_, _) {},
      );
      await Future<void>.delayed(Duration.zero);
      expect(repository.watchCallCount, 1);

      // Simulates sign-out: nothing watches this uid's profile anymore.
      firstSubscription.close();
      await Future<void>.delayed(Duration.zero);

      // Simulates signing back into the *same* account later in the same
      // app session. Without `autoDispose`, this would reuse the original
      // (now-unwatched, possibly permission-denied-from-signing-out)
      // provider instance and never call watchProfile again.
      final secondSubscription = container.listen(
        userProfileStreamProvider(uid),
        (_, _) {},
      );
      await Future<void>.delayed(Duration.zero);
      expect(repository.watchCallCount, 2);

      secondSubscription.close();
    },
  );
}
