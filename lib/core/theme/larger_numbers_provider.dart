import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/shared_preferences_provider.dart';

const _largerNumbersKey = 'larger_reading_numbers';

/// Persists the "Larger numbers" appearance preference
/// (`design_references/Settings.png`) via [sharedPreferencesProvider].
/// Defaults to off.
///
/// This only stores the preference for now — no screen reads it yet to
/// actually scale reading-value text sizes. Wiring it into Dashboard/
/// History/Reading detail/Trends is a separate, cross-cutting follow-up
/// (out of scope for a Settings-screen-only change).
class LargerNumbersNotifier extends Notifier<bool> {
  @override
  bool build() {
    return ref.watch(sharedPreferencesProvider).getBool(_largerNumbersKey) ?? false;
  }

  void setEnabled(bool enabled) {
    state = enabled;
    ref.read(sharedPreferencesProvider).setBool(_largerNumbersKey, enabled);
  }
}

final largerNumbersProvider = NotifierProvider<LargerNumbersNotifier, bool>(
  LargerNumbersNotifier.new,
);
