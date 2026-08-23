import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';

/// A small decorative pill badge — used for time-of-day/measurement-context
/// tags and category labels. Purely visual categorization, never meant to
/// imply medical meaning or severity (PROJECT_SPEC.md §9, §14).
class TagChip extends StatelessWidget {
  const TagChip({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: foreground, letterSpacing: 0),
      ),
    );
  }
}
