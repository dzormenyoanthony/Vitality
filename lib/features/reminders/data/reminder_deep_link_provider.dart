import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'reminder_providers.dart';

/// Tracks whether a reminder notification was tapped and the app still
/// needs to navigate to Record BP for it (PROJECT_SPEC.md §17's reminders
/// naturally lead into recording a measurement). Consumed once auth/
/// onboarding resolves to "ready" — see `VitalyApp` in `lib/main.dart`,
/// which listens both to this and to the auth gate so a cold-start tap
/// (received before auth resolves) isn't lost.
final _notificationTapStreamProvider = StreamProvider<void>((ref) {
  return ref.watch(notificationSchedulerProvider).notificationTapped;
});

class PendingDeepLinkNotifier extends Notifier<bool> {
  @override
  bool build() {
    ref.listen(_notificationTapStreamProvider, (previous, next) {
      if (next.hasValue) state = true;
    });
    return false;
  }

  void clear() => state = false;
}

final pendingDeepLinkProvider = NotifierProvider<PendingDeepLinkNotifier, bool>(
  PendingDeepLinkNotifier.new,
);
