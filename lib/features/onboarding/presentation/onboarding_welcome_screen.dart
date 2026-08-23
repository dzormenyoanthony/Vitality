import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';

/// Explains Vitaly's purpose and limitations before the user starts
/// recording data (PROJECT_SPEC.md §19).
class OnboardingWelcomeScreen extends StatelessWidget {
  const OnboardingWelcomeScreen({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_outline, size: 48, color: theme.colorScheme.primary),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'VITALY',
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Welcome to Vitaly', style: theme.textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Vitaly helps you record your blood pressure, see it recorded over time, '
            'and stay consistent with monitoring.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            "Vitaly does not diagnose conditions, prescribe medication, or replace "
            "a healthcare professional. It's a tool to help you organize your own "
            'measurements — always discuss your readings with a qualified professional.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(onPressed: onContinue, child: const Text('Continue')),
        ],
      ),
    );
  }
}
