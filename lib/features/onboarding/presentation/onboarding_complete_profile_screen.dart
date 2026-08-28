import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failure.dart';
import '../../../core/theme/app_colors.dart';
import '../../authentication/data/auth_providers.dart';
import 'onboarding_controller.dart';
import 'onboarding_name_screen.dart';

/// Fallback for an already-authenticated user whose profile is still
/// incomplete — a Google sign-in first-timer (no pre-auth name-collection
/// step to go through), or a legacy account from before onboarding moved
/// pre-auth. Reuses the same [OnboardingNameScreen] UI as the pre-auth
/// carousel's final step; only the destination of the submitted name
/// differs (written straight to the existing account's profile here,
/// instead of being held for a not-yet-created one).
class OnboardingCompleteProfileScreen extends ConsumerWidget {
  const OnboardingCompleteProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.onboardingPageBg,
      body: SafeArea(
        child: OnboardingNameScreen(
          onSubmit: (name) {
            final uid = ref.read(authStateChangesProvider).value?.uid;
            if (uid == null) return;
            ref
                .read(onboardingControllerProvider.notifier)
                .completeOnboarding(uid: uid, displayName: name);
          },
          isSubmitting: onboardingState.isLoading,
          errorMessage: onboardingState.hasError
              ? friendlyMessage(onboardingState.error!)
              : null,
        ),
      ),
    );
  }
}
