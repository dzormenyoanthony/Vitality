import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/onboarding_progress_dots.dart';

/// Third step of the onboarding carousel ("Onboarding 3 of 3" in
/// `design_references/`) — introduces reminders before the user starts
/// using Vitaly (PROJECT_SPEC.md §19).
///
/// Visual design matches `design_references/Onboarding 3 of 3.png`: a
/// lavender illustration card with decorative circles containing a mock
/// reminders card, a "ROUTINE" eyebrow badge, a bold headline, body copy,
/// a step-progress indicator, and a "Get started" action. Both "Skip" and
/// "Get started" call [onContinue] — matching the other carousel
/// screens' pattern.
class OnboardingRemindersScreen extends StatelessWidget {
  const OnboardingRemindersScreen({super.key, required this.onContinue});

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
                const AspectRatio(aspectRatio: 694 / 942, child: _RemindersIllustration()),
                const SizedBox(height: AppSpacing.lg),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.onboardingAccent3,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'ROUTINE',
                      style: theme.textTheme.labelMedium?.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Reminders that fit your day.',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppColors.onboardingHeadline3,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Set the times you measure. Vitaly nudges you, then gets out of '
                  'the way.',
                  style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.onboardingBody3),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
          child: Row(
            children: [
              const OnboardingProgressDots(
                total: 3,
                activeIndex: 2,
                activeColor: AppColors.onboardingAccent3,
                inactiveColor: AppColors.onboardingDotInactive,
              ),
              const Spacer(),
              FilledButton(
                onPressed: onContinue,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.onboardingAccent3,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Get started', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
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

/// The lavender illustration card with its two decorative circles and the
/// centered mock reminders card — purely decorative, not an interactive
/// preview of the real Reminders screen.
class _RemindersIllustration extends StatelessWidget {
  const _RemindersIllustration();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: ColoredBox(
        color: AppColors.onboardingIllustrationBg3,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            return Stack(
              children: [
                Positioned(
                  top: -height * 0.05,
                  right: -width * 0.12,
                  child: _Blob(diameter: width * 0.48, color: AppColors.onboardingIllustrationCircleBright3),
                ),
                Positioned(
                  bottom: -height * 0.03,
                  left: -width * 0.1,
                  child: _Blob(diameter: width * 0.42, color: AppColors.onboardingIllustrationCircleMuted3),
                ),
                Center(
                  child: FractionallySizedBox(widthFactor: 0.638, child: _MockRemindersCard()),
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

/// A small non-interactive mockup of a reminders card, used only as
/// onboarding illustration content.
class _MockRemindersCard extends StatelessWidget {
  const _MockRemindersCard();

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
          // Sized off width only — the card's height follows its content,
          // so nothing here can overflow regardless of screen height or
          // text-scale setting.
          final width = constraints.maxWidth;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.082, vertical: width * 0.06),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: width * 0.13,
                      height: width * 0.13,
                      decoration: BoxDecoration(
                        color: AppColors.onboardingIllustrationBg3,
                        borderRadius: BorderRadius.circular(width * 0.035),
                      ),
                      alignment: Alignment.center,
                      child: Icon(Icons.notifications_none, color: AppColors.onboardingAccent3, size: width * 0.075),
                    ),
                    SizedBox(width: width * 0.045),
                    Flexible(
                      child: Text(
                        'Two reminders a day',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.onboardingHeadline3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: width * 0.05),
                _MockReminderRow(time: '07:30', toggleColor: AppColors.onboardingAccent3, width: width),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: width * 0.03),
                  child: Divider(height: 1, color: Colors.black.withValues(alpha: 0.08)),
                ),
                _MockReminderRow(time: '20:15', toggleColor: AppColors.onboardingAccent, width: width),
                SizedBox(height: width * 0.06),
                _MockDayChipRow(width: width),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MockReminderRow extends StatelessWidget {
  const _MockReminderRow({required this.time, required this.toggleColor, required this.width});

  final String time;
  final Color toggleColor;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          time,
          style: TextStyle(
            color: AppColors.onboardingHeadline3,
            fontSize: width * 0.075,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        _MockToggle(color: toggleColor, width: width),
      ],
    );
  }
}

/// A static "on" toggle switch, matching the reference exactly — not the
/// real Material [Switch], since this is a fixed illustration state.
class _MockToggle extends StatelessWidget {
  const _MockToggle({required this.color, required this.width});

  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    final trackWidth = width * 0.13;
    final trackHeight = trackWidth * 0.56;
    return Container(
      width: trackWidth,
      height: trackHeight,
      padding: EdgeInsets.all(trackHeight * 0.1),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(trackHeight)),
      alignment: Alignment.centerRight,
      child: Container(
        width: trackHeight * 0.8,
        height: trackHeight * 0.8,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      ),
    );
  }
}

class _MockDayChipRow extends StatelessWidget {
  const _MockDayChipRow({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final chipSize = (width - width * 0.09 * 6) / 7;
    return Row(
      children: List.generate(7, (i) {
        final selected = i < 5;
        return Padding(
          padding: EdgeInsets.only(right: i == 6 ? 0 : width * 0.02),
          child: Container(
            width: chipSize,
            height: chipSize,
            decoration: BoxDecoration(
              color: selected ? AppColors.onboardingAccent3 : AppColors.onboardingIllustrationBg3,
              borderRadius: BorderRadius.circular(chipSize * 0.28),
            ),
          ),
        );
      }),
    );
  }
}
