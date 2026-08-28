import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vitality/core/services/shared_preferences_provider.dart';
import 'package:vitality/core/theme/larger_numbers_provider.dart';

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

  test('defaults to false when nothing is saved', () async {
    await buildContainer({});

    expect(container.read(largerNumbersProvider), isFalse);
  });

  test('setEnabled updates state and persists the choice', () async {
    await buildContainer({});

    container.read(largerNumbersProvider.notifier).setEnabled(true);

    expect(container.read(largerNumbersProvider), isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('larger_reading_numbers'), isTrue);
  });

  test('reads a previously persisted true value on startup', () async {
    await buildContainer({'larger_reading_numbers': true});

    expect(container.read(largerNumbersProvider), isTrue);
  });
}
