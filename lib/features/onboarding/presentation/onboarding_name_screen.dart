import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../authentication/domain/credentials_validator.dart';

/// Collects only a preferred name, per PROJECT_SPEC.md §19 — no age, sex,
/// height, weight, or medical history at account creation.
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
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('What should we call you?', style: theme.textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.md),
            Text(
              "We'll use this to personalize your dashboard.",
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _nameController,
              enabled: !widget.isSubmitting,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Preferred name'),
              validator: CredentialsValidator.validatePreferredName,
              onFieldSubmitted: (_) => _submit(),
            ),
            if (widget.errorMessage != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.errorMessage!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: widget.isSubmitting ? null : _submit,
              child: widget.isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Get started'),
            ),
          ],
        ),
      ),
    );
  }
}
