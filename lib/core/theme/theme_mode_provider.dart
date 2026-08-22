import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/shared_preferences_provider.dart';

const _themeModeKey = 'theme_mode';

/// Persists the chosen theme via [sharedPreferencesProvider]. Defaults to
/// following the system theme when nothing has been saved yet.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final saved = ref.watch(sharedPreferencesProvider).getString(_themeModeKey);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    ref.read(sharedPreferencesProvider).setString(_themeModeKey, mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
