import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
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
                    'VITALY',
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
                        TextSpan(text: 'A record of your ', style: TextStyle(color: AppColors.onboardingHeadline)),
                        TextSpan(text: 'blood pressure ', style: TextStyle(color: AppColors.onboardingAccent)),
                        TextSpan(text: 'over time.', style: TextStyle(color: AppColors.onboardingHeadline)),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Vitaly stores the readings you enter and shows how they change. '
                    'It does not interpret them or give medical advice.',
                    style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.onboardingBody),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'WHAT SHOULD WE CALL YOU?',
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
                    validator: CredentialsValidator.validatePreferredName,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (widget.errorMessage != null) ...[
                    Text(widget.errorMessage!, style: TextStyle(color: theme.colorScheme.error)),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  Text(
                    'Used only on this device. Nothing is uploaded.',
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
                        : const Text('Continue', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text('Step 1 of 1', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.onboardingBody)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
