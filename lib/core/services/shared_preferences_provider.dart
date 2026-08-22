import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Must be overridden in `main.dart` with an already-loaded instance
/// (`SharedPreferences.getInstance()` is async, so it can't be constructed
/// synchronously here) — tests override it with
/// `SharedPreferences.setMockInitialValues(...)` + `getInstance()` instead.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});
