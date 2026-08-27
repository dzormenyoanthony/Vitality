import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How long the branded [SplashScreen] stays on screen at minimum, even if
/// [authGateProvider] resolves before Flutter has produced a single frame
/// (e.g. a fresh install with no cached Firebase session, where
/// `authStateChanges()` can emit its first "signed out" event before the
/// first frame is drawn). Without this floor, the router's `redirect`
/// would carry the user straight from the native launch splash to
/// Onboarding/Sign In/Dashboard, and the Splash brand moment it was
/// designed around (PROJECT_SPEC.md, `design_references/Splash.png`) would
/// never actually be visible.
///
/// 2 seconds matches the range widely-used apps hold a splash for (roughly
/// 1.5-2.5s) - long enough to register as a deliberate brand beat, short
/// enough that it doesn't read as the app hanging on launch.
const splashMinDuration = Duration(seconds: 2);

/// Flips to `true` once [splashMinDuration] has elapsed since the app
/// started. The router's `redirect` keeps the user on `/` (Splash) until
/// this is true, regardless of how quickly the auth/onboarding gate itself
/// resolves.
class SplashMinDurationNotifier extends Notifier<bool> {
  @override
  bool build() {
    final timer = Timer(splashMinDuration, () => state = true);
    ref.onDispose(timer.cancel);
    return false;
  }
}

final splashMinDurationElapsedProvider =
    NotifierProvider<SplashMinDurationNotifier, bool>(
      SplashMinDurationNotifier.new,
    );
