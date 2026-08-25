import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/shared_preferences_provider.dart';

/// Shared with `main.dart`, which reads this key directly (before the
/// [ProviderScope] exists) to decide whether to sign out a restored Firebase
/// session on cold start.
const keepSignedInPrefsKey = 'keep_signed_in';

/// Whether a signed-in session should still be active the next time the app
/// is cold-started. Firebase Auth on mobile always persists a session by
/// itself, so this is enforced by `main.dart` explicitly signing the user
/// out on startup when this is `false` — unchecking it takes effect on the
/// next full app restart, not immediately.
///
/// Defaults to `true` (stay signed in) when nothing has been saved yet, so a
/// fresh install or a user who never touches the checkbox keeps the
/// unsurprising default behavior.
class KeepSignedInNotifier extends Notifier<bool> {
  @override
  bool build() {
    return ref.watch(sharedPreferencesProvider).getBool(keepSignedInPrefsKey) ??
        true;
  }

  void setKeepSignedIn(bool value) {
    state = value;
    ref.read(sharedPreferencesProvider).setBool(keepSignedInPrefsKey, value);
  }
}

final keepSignedInProvider = NotifierProvider<KeepSignedInNotifier, bool>(
  KeepSignedInNotifier.new,
);
