import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vitality/core/services/shared_preferences_provider.dart';
import 'package:vitality/features/onboarding/data/onboarding_intro_provider.dart';

void main() {
  test('defaults to false when nothing has been saved yet', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(container.read(onboardingIntroSeenProvider), isFalse);
  });

  test('markSeen flips state to true and persists it', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    container.read(onboardingIntroSeenProvider.notifier).markSeen();

    expect(container.read(onboardingIntroSeenProvider), isTrue);
    expect(prefs.getBool(onboardingIntroSeenPrefsKey), isTrue);
  });

  test('reads a previously persisted true value on a fresh container', () async {
    SharedPreferences.setMockInitialValues({onboardingIntroSeenPrefsKey: true});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(container.read(onboardingIntroSeenProvider), isTrue);
  });
}
