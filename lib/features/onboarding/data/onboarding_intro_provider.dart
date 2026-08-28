import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/shared_preferences_provider.dart';

/// Shared with nothing else — read only by the router's `redirect:`.
const onboardingIntroSeenPrefsKey = 'onboarding_intro_seen';

/// Whether *this device* has ever finished the pre-auth onboarding
/// carousel or reached a fully authenticated, onboarded state.
///
/// Distinct from the per-account `UserProfile.onboardingCompleted` in
/// Firestore: that's per-account and lives server-side; this is local-only
/// and decides whether a signed-out visitor on this device sees the intro
/// carousel again (brand-new) or goes straight to Sign In (an existing user
/// who's simply not currently signed in) — PROJECT_SPEC.md §30.
class OnboardingIntroSeenNotifier extends Notifier<bool> {
  @override
  bool build() {
    return ref
            .watch(sharedPreferencesProvider)
            .getBool(onboardingIntroSeenPrefsKey) ??
        false;
  }

  void markSeen() {
    if (state) return;
    state = true;
    ref.read(sharedPreferencesProvider).setBool(onboardingIntroSeenPrefsKey, true);
  }
}

final onboardingIntroSeenProvider =
    NotifierProvider<OnboardingIntroSeenNotifier, bool>(
      OnboardingIntroSeenNotifier.new,
    );
