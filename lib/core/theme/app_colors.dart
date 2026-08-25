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
  /// Sampled from `design_references/Dashboard.png`.
  static const Color heroFill = Color(0xFF0C4F4A);
  static const Color heroFillDark = Color(0xFF16443A);

  /// Warm CTA accent (FAB, primary "add" actions) — distinct from the
  /// brand teal so calls to action stand out.
  static const Color actionAccent = Color(0xFFD8654A);

  /// Dashboard-specific accents, sampled from
  /// `design_references/Dashboard.png` — the trend chart's systolic/
  /// diastolic lines, the "Add reading" FAB, and the greeting badge
  /// reuse the same teal/coral/mint family as the onboarding screens'
  /// reference art, but are kept as their own constants since this is a
  /// themed in-app screen rather than a fixed pre-auth brand moment.
  static const Color dashboardAccentTeal = Color(0xFF0F7A72);
  static const Color dashboardAccentCoral = Color(0xFFC2452C);
  static const Color dashboardBadgeBackground = Color(0xFFD7EFE9);

  /// Reminders-specific colors, sampled from
  /// `design_references/Reminders.png` — the small delivery-status dot
  /// next to each reminder row and the system-notifications-off warning
  /// banner. These describe notification *delivery* only, never a
  /// reading's severity (PROJECT_SPEC.md §9, §14 — see the Reminders
  /// screen's own footer copy, which says this explicitly).
  static const Color remindersDeliveringDot = Color(0xFF2E6B4F);
  static const Color remindersSilencedDot = Color(0xFF8A5300);
  static const Color remindersWarningBackground = Color(0xFFFBEEEC);
  static const Color remindersWarningDot = Color(0xFF9B2C20);

  /// Splash screen colors, sampled directly from
  /// `design_references/Splash.png` — independent of light/dark theme,
  /// since the splash is a fixed brand moment shown before the user's
  /// theme preference is relevant.
  static const Color splashBackground = Color(0xFF0C4F4A);
  static const Color splashBlobBright = Color(0xFF12665F);
  static const Color splashBlobSmall = Color(0xFF31554D);
  static const Color splashBlobBottom = Color(0xFF0A423E);

  /// Pale mint fill behind the splash icon, matching the reference —
  /// intentionally not [AppAccentColors.mintBackground] since this needs
  /// to stay legible against [splashBackground] regardless of app theme.
  static const Color splashIconBackground = Color(0xFFCDEBE5);

  /// Coral used only on the splash screen (wordmark dot, loading bar) —
  /// sampled from the reference, distinct from [actionAccent].
  static const Color splashAccent = Color(0xFFF2765C);
  static const Color splashProgressTrack = Color(0xFF3D726E);

  /// Onboarding carousel colors, sampled directly from
  /// `design_references/Onboarding 1 of 3.png` — independent of
  /// light/dark theme, matching the other fixed pre-auth brand screens.
  ///
  /// [onboardingPageBg] must be set explicitly as each onboarding screen's
  /// own Scaffold background — these screens' text colors are tuned for a
  /// fixed light page, so leaving the Scaffold to inherit the app theme's
  /// background (near-black in dark mode) makes that text unreadable.
  static const Color onboardingPageBg = Color(0xFFF2F7F5);
  static const Color onboardingIllustrationBg = Color(0xFFD7EFE9);
  static const Color onboardingIllustrationCircleBright = Color(0xFFC3E3DD);
  static const Color onboardingIllustrationCircleMuted = Color(0xFFDBDED5);
  static const Color onboardingAccent = Color(0xFF0F7A72);
  static const Color onboardingHeadline = Color(0xFF0E2724);
  static const Color onboardingBody = Color(0xFF475B58);
  static const Color onboardingCoral = Color(0xFFC2452C);
  static const Color onboardingChipUnselected = Color(0xFFEDF5F3);
  static const Color onboardingDotInactive = Color(0xFFC9D1CF);

  /// Onboarding 2-of-3 colors, sampled from
  /// `design_references/Onboarding 2 of 3.png` — a separate warm/coral
  /// palette from screen 1's mint/teal one.
  static const Color onboardingPageBg2 = Color(0xFFFFF6F2);
  static const Color onboardingIllustrationBg2 = Color(0xFFFFE0D6);
  static const Color onboardingIllustrationCircleBright2 = Color(0xFFF9D0C4);
  static const Color onboardingIllustrationCircleMuted2 = Color(0xFFE2D4CA);
  static const Color onboardingHeadline2 = Color(0xFF3A140C);
  static const Color onboardingBody2 = Color(0xFF6B4D46);
  static const Color onboardingChartFill = Color(0xFFE7F1F1);
  static const Color onboardingDiastolicLine = Color(0xFFF2765C);

  /// Onboarding 3-of-3 colors, sampled from
  /// `design_references/Onboarding 3 of 3.png` — a separate
  /// indigo/lavender palette from screens 1-2.
  static const Color onboardingPageBg3 = Color(0xFFF6F4FF);
  static const Color onboardingIllustrationBg3 = Color(0xFFE3DEFF);
  static const Color onboardingIllustrationCircleBright3 = Color(0xFFD2CCFB);
  static const Color onboardingIllustrationCircleMuted3 = Color(0xFFC9D2EE);
  static const Color onboardingAccent3 = Color(0xFF5B4BE0);
  static const Color onboardingHeadline3 = Color(0xFF221A57);
  static const Color onboardingBody3 = Color(0xFF575081);

  /// Onboarding name-entry screen — sampled from
  /// `design_references/Onboarding-name only.png`. The wordmark,
  /// headline accent, and button all reuse [onboardingAccent] and
  /// [onboardingHeadline]/[onboardingBody] exactly (same teal/dark-teal
  /// palette as Onboarding 1 of 3); only the field border is new.
  static const Color onboardingFieldBorder = Color(0xFF566A65);

  /// Reading detail's "SAME TIME OF DAY" bar chart, sampled from
  /// `design_references/Reading.png` — a medium mint fill for the
  /// non-highlighted bars. The highlighted (current) bar reuses
  /// [dashboardAccentTeal] instead of a new color, matching the reference.
  /// Purely decorative/comparative, never severity-coded (PROJECT_SPEC.md
  /// §9, §14) — fixed across themes like the other chart accents above.
  static const Color readingBarFill = Color(0xFF9AD0C0);

  /// Sign In screen's decorative blob, sampled from
  /// `design_references/Sign In screen.png` — a warm sandy tan, distinct
  /// from [onboardingIllustrationCircleBright2]'s pinker peach.
  static const Color signInAccentTan = Color(0xFFEFC08D);
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
      purpleBackground: Color.lerp(
        purpleBackground,
        other.purpleBackground,
        t,
      )!,
      purpleForeground: Color.lerp(
        purpleForeground,
        other.purpleForeground,
        t,
      )!,
      blueBackground: Color.lerp(blueBackground, other.blueBackground, t)!,
      blueForeground: Color.lerp(blueForeground, other.blueForeground, t)!,
    );
  }
}
