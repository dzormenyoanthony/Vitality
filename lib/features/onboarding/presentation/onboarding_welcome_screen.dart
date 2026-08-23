import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';

/// First step of the onboarding carousel ("Onboarding 1 of 3" in
/// `design_references/`) — introduces recording a reading before the user
/// starts using Vitaly (PROJECT_SPEC.md §19).
///
/// Visual design matches `design_references/Onboarding 1 of 3.png`: a
/// mint illustration card with decorative circles containing a mock
/// "new reading" card, a "LOG" eyebrow badge, a bold headline, body copy,
/// a step-progress indicator, and a "Next" action. [onContinue] both
/// "Skip" and "Next" call through to — this screen doesn't yet have a
/// second onboarding step to distinguish them functionally.
class OnboardingWelcomeScreen extends StatelessWidget {
  const OnboardingWelcomeScreen({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onContinue,
                    child: Text(
                      'Skip',
                      style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const AspectRatio(aspectRatio: 694 / 942, child: _ReadingIllustration()),
                const SizedBox(height: AppSpacing.lg),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.onboardingAccent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'LOG',
                      style: theme.textTheme.labelMedium?.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Two numbers, five seconds.',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppColors.onboardingHeadline,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Systolic and diastolic are all Vitaly needs. Pulse, posture and '
                  'notes are there when you want them.',
                  style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.onboardingBody),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
          child: Row(
            children: [
              _ProgressDots(total: 3, activeIndex: 0),
              const Spacer(),
              FilledButton(
                onPressed: onContinue,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.onboardingAccent,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Next', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    SizedBox(width: AppSpacing.sm),
                    Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Step-progress indicator — an elongated pill for the active step, small
/// dots for the rest, matching `design_references/Onboarding 1 of 3.png`.
class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.total, required this.activeIndex});

  final int total;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final active = i == activeIndex;
        return Padding(
          padding: EdgeInsets.only(right: i == total - 1 ? 0 : AppSpacing.xs),
          child: Container(
            width: active ? 28 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: active ? AppColors.onboardingAccent : AppColors.onboardingDotInactive,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}

/// The mint illustration card with its two decorative circles and the
/// centered mock "new reading" card — purely decorative, not an
/// interactive preview of the real Record BP screen.
class _ReadingIllustration extends StatelessWidget {
  const _ReadingIllustration();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: ColoredBox(
        color: AppColors.onboardingIllustrationBg,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            return Stack(
              children: [
                Positioned(
                  top: -height * 0.05,
                  right: -width * 0.12,
                  child: _Blob(diameter: width * 0.48, color: AppColors.onboardingIllustrationCircleBright),
                ),
                Positioned(
                  bottom: -height * 0.03,
                  left: -width * 0.1,
                  child: _Blob(diameter: width * 0.42, color: AppColors.onboardingIllustrationCircleMuted),
                ),
                Center(
                  child: FractionallySizedBox(widthFactor: 0.638, child: _MockReadingCard()),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.diameter, required this.color});

  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// A small non-interactive mockup of the Record BP card, used only as
/// onboarding illustration content.
class _MockReadingCard extends StatelessWidget {
  const _MockReadingCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Sized off width only (via the FractionallySizedBox above) — the
          // card's height follows its content, so nothing here can overflow
          // regardless of screen height or text-scale setting.
          final width = constraints.maxWidth;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.09, vertical: width * 0.055),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NEW READING',
                  style: theme.textTheme.labelMedium?.copyWith(color: AppColors.onboardingAccent),
                ),
                SizedBox(height: width * 0.025),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '128',
                        style: TextStyle(
                          color: AppColors.onboardingHeadline,
                          fontSize: width * 0.15,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                      SizedBox(width: width * 0.025),
                      Padding(
                        padding: EdgeInsets.only(bottom: width * 0.015),
                        child: Text(
                          '/',
                          style: TextStyle(color: Colors.black26, fontSize: width * 0.1),
                        ),
                      ),
                      SizedBox(width: width * 0.025),
                      Text(
                        '82',
                        style: TextStyle(
                          color: AppColors.onboardingHeadline,
                          fontSize: width * 0.15,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                      SizedBox(width: width * 0.025),
                      Padding(
                        padding: EdgeInsets.only(bottom: width * 0.015),
                        child: Text(
                          'mmHg',
                          style: TextStyle(color: Colors.black45, fontSize: width * 0.05),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: width * 0.035),
                _MockChipGrid(selectedIndex: 4),
                SizedBox(height: width * 0.03),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: width * 0.022),
                  decoration: BoxDecoration(
                    color: AppColors.onboardingCoral,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Save reading',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: width * 0.075),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 3x2 grid of small placeholder chips, one shown selected — matching the
/// mock reading card's context-tag grid in the reference.
class _MockChipGrid extends StatelessWidget {
  const _MockChipGrid({required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final chipWidth = (constraints.maxWidth - constraints.maxWidth * 0.07) / 3;
        final chipHeight = chipWidth * 0.42;

        return Wrap(
          spacing: constraints.maxWidth * 0.035,
          runSpacing: constraints.maxWidth * 0.035,
          children: List.generate(6, (i) {
            final selected = i == selectedIndex;
            return Container(
              width: chipWidth,
              height: chipHeight,
              decoration: BoxDecoration(
                color: selected ? AppColors.onboardingAccent : AppColors.onboardingChipUnselected,
                borderRadius: BorderRadius.circular(chipHeight * 0.25),
              ),
            );
          }),
        );
      },
    );
  }
}
