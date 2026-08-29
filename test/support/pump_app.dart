import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:vitality/l10n/app_localizations.dart';

/// Test helpers for the generated [AppLocalizations] (PROJECT_SPEC.md §36).
///
/// Widget tests build their own `MaterialApp`, so any test that renders a
/// screen reading localized strings needs the app's localization delegates
/// wired in. Prefer [pumpApp]; drop [localizationWrappers] into a
/// hand-rolled `MaterialApp` when a test needs finer control.

/// The delegate list every localized widget test must supply.
const List<LocalizationsDelegate<Object?>> localizationWrappers =
    AppLocalizations.localizationsDelegates;

const List<Locale> testSupportedLocales = AppLocalizations.supportedLocales;

/// Pumps [child] inside a localized [MaterialApp], optionally under a
/// [ProviderScope] with [overrides]. [locale] forces a specific locale
/// (defaults to the device/en).
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const [],
  Locale? locale,
  NavigatorObserver? navigatorObserver,
}) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: localizationWrappers,
        supportedLocales: testSupportedLocales,
        navigatorObservers: [?navigatorObserver],
        home: child,
      ),
    ),
  );
}

/// Loads an [AppLocalizations] instance without a widget tree — for domain
/// / controller tests that assemble user-facing strings directly
/// (Phase 6 of the §36 work).
Future<AppLocalizations> loadAppLocalizations([
  Locale locale = const Locale('en'),
]) {
  return AppLocalizations.delegate.load(locale);
}
