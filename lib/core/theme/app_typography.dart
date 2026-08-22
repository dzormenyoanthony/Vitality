import 'package:flutter/material.dart';

/// Centralized text theme overrides.
///
/// Uses the Material 3 default type scale (system font) rather than a
/// custom typeface, keeping the dependency footprint minimal while still
/// centralizing sizing/weight decisions in one place.
abstract final class AppTypography {
  static TextTheme textTheme(TextTheme base) {
    return base.copyWith(
      headlineMedium: base.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: base.bodyLarge?.copyWith(height: 1.4),
      bodyMedium: base.bodyMedium?.copyWith(height: 1.4),
    );
  }
}
