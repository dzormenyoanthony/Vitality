import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/core/paywall/onboarding_completion_detector.dart';
import 'package:vitality/core/router/auth_gate_provider.dart';

void main() {
  late OnboardingCompletionDetector detector;

  setUp(() => detector = OnboardingCompletionDetector());

  /// Feeds [states] in order and returns what the final `onGateState`
  /// call reported — i.e. whether the paywall should be offered now.
  bool feed(Iterable<AuthGateState> states) {
    var offerPaywall = false;
    for (final state in states) {
      offerPaywall = detector.onGateState(state);
    }
    return offerPaywall;
  }

  test('fires on NeedsOnboarding -> Ready (the Google / legacy path)', () {
    expect(
      feed(const [
        AuthGateLoading(),
        AuthGateNeedsOnboarding('u1'),
        AuthGateReady('u1', 'Sam'),
      ]),
      isTrue,
    );
  });

  test('does not fire for a returning user booting straight to Ready', () {
    expect(
      feed(const [AuthGateLoading(), AuthGateReady('u1', 'Sam')]),
      isFalse,
    );
  });

  test(
    'still fires when the gate ticks through Loading between '
    'NeedsOnboarding and Ready',
    () {
      expect(
        feed(const [
          AuthGateLoading(),
          AuthGateNeedsOnboarding('u1'),
          AuthGateLoading(),
          AuthGateReady('u1', 'Sam'),
        ]),
        isTrue,
      );
    },
  );

  test('a transient error between NeedsOnboarding and Ready keeps the latch', () {
    expect(
      feed(const [
        AuthGateNeedsOnboarding('u1'),
        AuthGateError('u1', 'Unable to load your profile.'),
        AuthGateReady('u1', 'Sam'),
      ]),
      isTrue,
    );
  });

  test('fires only once — a later Ready (e.g. display-name change) does not', () {
    detector.onGateState(const AuthGateNeedsOnboarding('u1'));
    expect(detector.onGateState(const AuthGateReady('u1', 'Sam')), isTrue);
    expect(detector.onGateState(const AuthGateReady('u1', 'Samuel')), isFalse);
  });

  test('sign-out clears the latch so the next account starts fresh', () {
    detector.onGateState(const AuthGateNeedsOnboarding('u1'));
    detector.onGateState(const AuthGateUnauthenticated());
    // A different, already-onboarded account signs in on the same device.
    expect(detector.onGateState(const AuthGateReady('u2', 'Alex')), isFalse);
  });
}
