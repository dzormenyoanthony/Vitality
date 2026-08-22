import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vitality/core/services/shared_preferences_provider.dart';
import 'package:vitality/core/theme/theme_mode_provider.dart';

void main() {
  late ProviderContainer container;

  Future<void> buildContainer(Map<String, Object> initialValues) async {
    SharedPreferences.setMockInitialValues(initialValues);
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
  }

  tearDown(() => container.dispose());

  test('defaults to ThemeMode.system when nothing is saved', () async {
    await buildContainer({});

    expect(container.read(themeModeProvider), ThemeMode.system);
  });

  test('setThemeMode updates state and persists the choice', () async {
    await buildContainer({});

    container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);

    expect(container.read(themeModeProvider), ThemeMode.dark);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('theme_mode'), 'dark');
  });

  test('reads a previously persisted choice on startup', () async {
    await buildContainer({'theme_mode': 'light'});

    expect(container.read(themeModeProvider), ThemeMode.light);
  });

  test('falls back to system for an unrecognized saved value', () async {
    await buildContainer({'theme_mode': 'not-a-real-mode'});

    expect(container.read(themeModeProvider), ThemeMode.system);
  });
}
