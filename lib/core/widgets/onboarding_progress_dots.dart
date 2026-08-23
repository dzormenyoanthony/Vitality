import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';

/// Step-progress indicator shared by the onboarding carousel screens — an
/// elongated pill for the active step, small dots for the rest, matching
/// `design_references/Onboarding {1,2,3} of 3.png`. Each screen uses its
/// own accent color for the active pill.
class OnboardingProgressDots extends StatelessWidget {
  const OnboardingProgressDots({
    super.key,
    required this.total,
    required this.activeIndex,
    required this.activeColor,
    required this.inactiveColor,
  });

  final int total;
  final int activeIndex;
  final Color activeColor;
  final Color inactiveColor;

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
              color: active ? activeColor : inactiveColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}
