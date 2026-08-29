import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../authentication/domain/credentials_validator.dart';

/// Collects only a preferred name, per PROJECT_SPEC.md §19 — no age, sex,
/// height, weight, or medical history at account creation.
///
/// Visual design matches `design_references/Onboarding-name only.png`: a
/// left-aligned "VITALY" wordmark, a multi-color headline, body copy, a
/// bordered name field with an eyebrow label and privacy caption, a
/// "Continue" action, and a "Step 1 of 1" footer.
class OnboardingNameScreen extends StatefulWidget {
  const OnboardingNameScreen({
    super.key,
    required this.onSubmit,
    required this.isSubmitting,
    this.errorMessage,
  });

  final ValueChanged<String> onSubmit;
  final bool isSubmitting;
  final String? errorMessage;

  @override
  State<OnboardingNameScreen> createState() => _OnboardingNameScreenState();
}

class _OnboardingNameScreenState extends State<OnboardingNameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit(_nameController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    l10n.splashWordmark,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.onboardingAccent,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text.rich(
                    TextSpan(
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, height: 1.15),
                      children: [
                        TextSpan(text: l10n.onboardingNameTitlePart1, style: const TextStyle(color: AppColors.onboardingHeadline)),
                        TextSpan(text: l10n.onboardingNameTitleEmphasis, style: const TextStyle(color: AppColors.onboardingAccent)),
                        TextSpan(text: l10n.onboardingNameTitlePart2, style: const TextStyle(color: AppColors.onboardingHeadline)),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.onboardingNameBody,
                    style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.onboardingBody),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    l10n.onboardingNameFieldLabel,
                    style: theme.textTheme.labelMedium?.copyWith(color: AppColors.onboardingBody),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _nameController,
                    enabled: !widget.isSubmitting,
                    textCapitalization: TextCapitalization.words,
                    style: TextStyle(color: AppColors.onboardingHeadline, fontSize: 18),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        borderSide: const BorderSide(color: AppColors.onboardingFieldBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        borderSide: const BorderSide(color: AppColors.onboardingAccent, width: 2),
                      ),
                    ),
                    validator: (v) => CredentialsValidator.validatePreferredName(l10n, v),
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (widget.errorMessage != null) ...[
                    Text(widget.errorMessage!, style: TextStyle(color: theme.colorScheme.error)),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  Text(
                    l10n.onboardingNamePrivacyCaption,
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.onboardingBody),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: widget.isSubmitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.onboardingAccent,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    child: widget.isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(l10n.commonContinue, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(l10n.onboardingNameStepFooter, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.onboardingBody)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
