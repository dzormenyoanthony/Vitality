import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/auth_gate_provider.dart';
import '../../../core/theme/app_colors.dart';
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

    if (gate case AuthGateError(:final uid, :final message)) {
      return Scaffold(
        body: ErrorView(
          message: message,
          onRetry: () => ref.invalidate(userProfileStreamProvider(uid)),
        ),
      );
    }

    final brightness = Theme.of(context).brightness;
    final fill = brightness == Brightness.dark ? AppColors.heroFillDark : AppColors.heroFill;

    return Scaffold(
      backgroundColor: fill,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: _Blob(diameter: 260, color: Colors.white.withValues(alpha: 0.08)),
          ),
          Positioned(
            top: 120,
            left: -80,
            child: _Blob(diameter: 180, color: Colors.white.withValues(alpha: 0.05)),
          ),
          Positioned(
            bottom: -60,
            left: -40,
            child: _Blob(diameter: 220, color: Colors.white.withValues(alpha: 0.06)),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(Icons.favorite_outline, size: 40, color: fill),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'VITALY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your health and wellness companion',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.diameter, required this.color});

  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
