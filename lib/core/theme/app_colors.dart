import 'package:flutter/material.dart';

/// Seed color and shared palette for Vitaly's light/dark themes.
///
/// A calm teal/green reads as "health and wellness" without leaning on
/// clinical red or alarm-coded colors (PROJECT_SPEC.md §9: avoid
/// unnecessarily alarming users).
abstract final class AppColors {
  static const Color seed = Color(0xFF2E7D6B);

  /// Solid fill for the Dashboard's "latest reading" hero card — a
  /// deliberate one-off dark-teal treatment, not part of the M3 seed ramp.
  static const Color heroFill = Color(0xFF123D33);
  static const Color heroFillDark = Color(0xFF16443A);

  /// Warm CTA accent (FAB, primary "add" actions) — distinct from the
  /// brand teal so calls to action stand out.
  static const Color actionAccent = Color(0xFFD8654A);
}

/// Four decorative (background, foreground) accent pairs used for
/// non-medical categorical badges — time-of-day tags, measurement-context
/// tags, stat tiles. Colors here are purely for visual distinction; they
/// never encode severity or medical meaning (PROJECT_SPEC.md §9, §14).
@immutable
class AppAccentColors extends ThemeExtension<AppAccentColors> {
  const AppAccentColors({
    required this.mintBackground,
    required this.mintForeground,
    required this.coralBackground,
    required this.coralForeground,
    required this.purpleBackground,
    required this.purpleForeground,
    required this.blueBackground,
    required this.blueForeground,
  });

  final Color mintBackground;
  final Color mintForeground;
  final Color coralBackground;
  final Color coralForeground;
  final Color purpleBackground;
  final Color purpleForeground;
  final Color blueBackground;
  final Color blueForeground;

  static const light = AppAccentColors(
    mintBackground: Color(0xFFD9EEE4),
    mintForeground: Color(0xFF1F5C4E),
    coralBackground: Color(0xFFFBDCCF),
    coralForeground: Color(0xFFB3502F),
    purpleBackground: Color(0xFFE7E1FB),
    purpleForeground: Color(0xFF5B4FCF),
    blueBackground: Color(0xFFDCEAF8),
    blueForeground: Color(0xFF3B6FA0),
  );

  static const dark = AppAccentColors(
    mintBackground: Color(0xFF1B4238),
    mintForeground: Color(0xFFAEE0CD),
    coralBackground: Color(0xFF4A2A1D),
    coralForeground: Color(0xFFF3B79B),
    purpleBackground: Color(0xFF2E2A4D),
    purpleForeground: Color(0xFFC6BEFA),
    blueBackground: Color(0xFF213548),
    blueForeground: Color(0xFFA9CBEA),
  );

  /// The 4 pairs in a fixed order, for decorative cycling
  /// (e.g. `accents[key.index % accents.length]`) — never meant to imply
  /// ranking or severity.
  List<(Color background, Color foreground)> get accents => [
    (mintBackground, mintForeground),
    (coralBackground, coralForeground),
    (purpleBackground, purpleForeground),
    (blueBackground, blueForeground),
  ];

  @override
  AppAccentColors copyWith({
    Color? mintBackground,
    Color? mintForeground,
    Color? coralBackground,
    Color? coralForeground,
    Color? purpleBackground,
    Color? purpleForeground,
    Color? blueBackground,
    Color? blueForeground,
  }) {
    return AppAccentColors(
      mintBackground: mintBackground ?? this.mintBackground,
      mintForeground: mintForeground ?? this.mintForeground,
      coralBackground: coralBackground ?? this.coralBackground,
      coralForeground: coralForeground ?? this.coralForeground,
      purpleBackground: purpleBackground ?? this.purpleBackground,
      purpleForeground: purpleForeground ?? this.purpleForeground,
      blueBackground: blueBackground ?? this.blueBackground,
      blueForeground: blueForeground ?? this.blueForeground,
    );
  }

  @override
  AppAccentColors lerp(ThemeExtension<AppAccentColors>? other, double t) {
    if (other is! AppAccentColors) return this;
    return AppAccentColors(
      mintBackground: Color.lerp(mintBackground, other.mintBackground, t)!,
      mintForeground: Color.lerp(mintForeground, other.mintForeground, t)!,
      coralBackground: Color.lerp(coralBackground, other.coralBackground, t)!,
      coralForeground: Color.lerp(coralForeground, other.coralForeground, t)!,
      purpleBackground: Color.lerp(purpleBackground, other.purpleBackground, t)!,
      purpleForeground: Color.lerp(purpleForeground, other.purpleForeground, t)!,
      blueBackground: Color.lerp(blueBackground, other.blueBackground, t)!,
      blueForeground: Color.lerp(blueForeground, other.blueForeground, t)!,
    );
  }
}
