import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Light and dark [ThemeData] for Vitaly.
///
/// All screens must build on these themes rather than hard-coding colors
/// or text styles (PROJECT_SPEC.md §21).
abstract final class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: Brightness.light,
    );
    return _themeFrom(colorScheme, AppAccentColors.light);
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: Brightness.dark,
    );
    return _themeFrom(colorScheme, AppAccentColors.dark);
  }

  static ThemeData _themeFrom(ColorScheme colorScheme, AppAccentColors accents) {
    final base = ThemeData(colorScheme: colorScheme, useMaterial3: true);
    return base.copyWith(
      textTheme: AppTypography.textTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      scaffoldBackgroundColor: colorScheme.surface,
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: StadiumBorder(side: BorderSide(color: colorScheme.outlineVariant)),
        selectedColor: colorScheme.primaryContainer,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.actionAccent,
        foregroundColor: Colors.white,
      ),
      extensions: [accents],
    );
  }
}
