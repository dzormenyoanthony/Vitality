import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failure.dart';
import '../../../core/theme/app_colors.dart';
import '../../authentication/data/auth_providers.dart';
import 'onboarding_controller.dart';
import 'onboarding_name_screen.dart';
import 'onboarding_reminders_screen.dart';
import 'onboarding_trends_screen.dart';
import 'onboarding_welcome_screen.dart';

/// Hosts the onboarding carousel (Onboarding 1 of 3 → 2 of 3 → 3 of 3 →
/// preferred name) behind a single `/onboarding` route.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;

  void _submitName(String name) {
    final uid = ref.read(authStateChangesProvider).value?.uid;
    if (uid == null) return;
    ref.read(onboardingControllerProvider.notifier).completeOnboarding(
      uid: uid,
      displayName: name,
    );
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingControllerProvider);

    final Widget step;
    final Color background;
    switch (_step) {
      case 0:
        step = OnboardingWelcomeScreen(onContinue: () => setState(() => _step = 1));
        background = AppColors.onboardingPageBg;
      case 1:
        step = OnboardingTrendsScreen(onContinue: () => setState(() => _step = 2));
        background = AppColors.onboardingPageBg2;
      case 2:
        step = OnboardingRemindersScreen(onContinue: () => setState(() => _step = 3));
        background = AppColors.onboardingPageBg3;
      default:
        step = OnboardingNameScreen(
          onSubmit: _submitName,
          isSubmitting: onboardingState.isLoading,
          errorMessage: onboardingState.hasError ? friendlyMessage(onboardingState.error!) : null,
        );
        background = AppColors.onboardingPageBg;
    }

    // Each onboarding screen is a fixed pre-auth brand moment (like Splash)
    // with text colors tuned for its own light page background — pin that
    // background explicitly rather than inheriting the app theme's, which
    // would make the text unreadable in dark mode.
    return Scaffold(backgroundColor: background, body: SafeArea(child: step));
  }
}
