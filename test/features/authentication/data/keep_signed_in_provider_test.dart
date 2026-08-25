import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vitality/core/services/shared_preferences_provider.dart';
import 'package:vitality/features/authentication/data/keep_signed_in_provider.dart';

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

  test('defaults to true when nothing is saved', () async {
    await buildContainer({});

    expect(container.read(keepSignedInProvider), isTrue);
  });

  test('setKeepSignedIn updates state and persists the choice', () async {
    await buildContainer({});

    container.read(keepSignedInProvider.notifier).setKeepSignedIn(false);

    expect(container.read(keepSignedInProvider), isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(keepSignedInPrefsKey), isFalse);
  });

  test('reads a previously persisted false choice on startup', () async {
    await buildContainer({keepSignedInPrefsKey: false});

    expect(container.read(keepSignedInProvider), isFalse);
  });
}
