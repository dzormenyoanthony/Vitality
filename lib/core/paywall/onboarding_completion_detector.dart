import '../router/auth_gate_provider.dart';

/// Recognises the single moment a user *finishes* onboarding — the
/// [AuthGateReady] that follows an [AuthGateNeedsOnboarding] — so the
/// caller can offer the one-time post-onboarding paywall then, and only
/// then.
///
/// It's a latch on "this session passed through [AuthGateNeedsOnboarding]"
/// rather than a plain `previous is AuthGateNeedsOnboarding` check: the
/// auth gate can tick briefly through [AuthGateLoading] as the profile
/// stream re-resolves between the two states, and that must not hide the
/// completion. A returning user whose session boots straight to
/// [AuthGateReady] never trips it.
class OnboardingCompletionDetector {
  bool _sawNeedsOnboarding = false;

  /// Feed every [AuthGateState] the gate emits, in order. Returns `true`
  /// exactly once per completed onboarding: on the first [AuthGateReady]
  /// after an [AuthGateNeedsOnboarding]. Signing out ([AuthGateUnauthenticated])
  /// clears the latch so the next account on the same device is judged
  /// from scratch.
  bool onGateState(AuthGateState state) {
    switch (state) {
      case AuthGateNeedsOnboarding():
        _sawNeedsOnboarding = true;
        return false;
      case AuthGateReady():
        final justOnboarded = _sawNeedsOnboarding;
        _sawNeedsOnboarding = false;
        return justOnboarded;
      case AuthGateUnauthenticated():
        _sawNeedsOnboarding = false;
        return false;
      case AuthGateLoading():
      case AuthGateError():
        return false;
    }
  }
}
