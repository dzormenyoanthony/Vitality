import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failure.dart';
import '../../authentication/data/auth_providers.dart';
import 'onboarding_controller.dart';
import 'onboarding_name_screen.dart';
import 'onboarding_welcome_screen.dart';

/// Hosts the two-step onboarding flow (welcome → preferred name) behind a
/// single `/onboarding` route.
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

    return Scaffold(
      body: SafeArea(
        child: _step == 0
            ? OnboardingWelcomeScreen(onContinue: () => setState(() => _step = 1))
            : OnboardingNameScreen(
                onSubmit: _submitName,
                isSubmitting: onboardingState.isLoading,
                errorMessage: onboardingState.hasError
                    ? friendlyMessage(onboardingState.error!)
                    : null,
              ),
      ),
    );
  }
}
