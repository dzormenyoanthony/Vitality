import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/auth_gate_provider.dart';
import '../../../core/widgets/error_view.dart';
import '../../onboarding/data/user_profile_providers.dart';

/// Resolving/entry screen shown while [authGateProvider] determines whether
/// the user is signed in and onboarded (PROJECT_SPEC.md §30).
///
/// Also doubles as the error state for that resolution (e.g. a Firestore
/// permission or connectivity failure loading the user's profile) — the
/// auth gate must never be allowed to hang silently on a loading spinner
/// (CLAUDE.md §24).
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gate = ref.watch(authGateProvider);
    final theme = Theme.of(context);

    if (gate case AuthGateError(:final uid, :final message)) {
      return Scaffold(
        body: ErrorView(
          message: message,
          onRetry: () => ref.invalidate(userProfileStreamProvider(uid)),
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite_outline,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text('Vitaly', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Your health and wellness companion',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
