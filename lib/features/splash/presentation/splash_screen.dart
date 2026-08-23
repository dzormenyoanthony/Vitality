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
///
/// Visual design matches `design_references/Splash.png`: dark-teal hero
/// background, three overlapping circles (one brighter, two darker/muted,
/// each its own shade), a rounded-square icon badge with a pulse waveform,
/// the "VITALY" wordmark with a coral accent dot, a tagline, and a bottom
/// loading bar. Geometry and colors below are measured directly from that
/// reference image, expressed as fractions of the screen so they hold up
/// across device sizes.
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

    const fill = AppColors.splashBackground;

    return Scaffold(
      backgroundColor: fill,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final iconSize = width * 0.241;

          return Stack(
            children: [
              // Large, brighter circle — top-right, cut off by the top and
              // right edges.
              Positioned(
                top: -height * 0.1105,
                right: -width * 0.175,
                child: _Blob(diameter: width * 0.705, color: AppColors.splashBlobBright),
              ),
              // Small circle — left edge, upper-mid height.
              Positioned(
                top: height * 0.185,
                left: -width * 0.1006,
                child: _Blob(diameter: width * 0.377, color: AppColors.splashBlobSmall),
              ),
              // Large circle — bottom-left, mostly offscreen so only its
              // top arc shows as a band near the bottom.
              Positioned(
                bottom: -height * 0.1285,
                left: -width * 0.194,
                child: _Blob(diameter: width * 0.717, color: AppColors.splashBlobBottom),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: iconSize,
                        height: iconSize,
                        decoration: BoxDecoration(
                          color: AppColors.splashIconBackground,
                          borderRadius: BorderRadius.circular(iconSize * 0.3),
                        ),
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: iconSize * 0.44,
                          height: iconSize * 0.44,
                          child: CustomPaint(painter: _PulsePainter(color: fill)),
                        ),
                      ),
                      SizedBox(height: height * 0.035),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'VITALY',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 9,
                            height: 9,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: const BoxDecoration(
                              color: AppColors.splashAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: height * 0.035),
                      const Text(
                        'Blood pressure, recorded',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: height * 0.07,
                child: Center(
                  child: SizedBox(
                    width: width * 0.33,
                    height: 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: const LinearProgressIndicator(
                        backgroundColor: AppColors.splashProgressTrack,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.splashAccent),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
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

/// Draws the same simple heartbeat/pulse waveform shown in
/// `design_references/Splash.png` — no built-in Material icon matches it
/// (the closest, `monitor_heart_outlined`, also draws a heart outline the
/// reference doesn't have).
class _PulsePainter extends CustomPainter {
  const _PulsePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(0, h * 0.55)
      ..lineTo(w * 0.22, h * 0.55)
      ..lineTo(w * 0.36, h * 0.15)
      ..lineTo(w * 0.5, h * 0.85)
      ..lineTo(w * 0.64, h * 0.4)
      ..lineTo(w * 0.78, h * 0.55)
      ..lineTo(w, h * 0.55);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PulsePainter oldDelegate) => oldDelegate.color != color;
}
