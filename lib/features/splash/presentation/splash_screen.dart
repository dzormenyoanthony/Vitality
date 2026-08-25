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
/// Visual design matches `design_references/Splash.png`: a radial dark-teal
/// background, two overlapping translucent circles, faint concentric rings
/// centered on the icon, a rounded-square icon badge with a pulse waveform,
/// the "VITALY" wordmark with a coral accent dot, a floating coral dot and
/// mint dot, a horizontal heartbeat trace, a tagline, a bottom loading bar,
/// and a "NOT A MEDICAL DEVICE" caption. Geometry and colors below are
/// measured directly from that reference image, expressed as fractions of
/// the screen so they hold up across device sizes.
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
          final iconCenter = Offset(width / 2, height * 0.475);

          return Stack(
            children: [
              // Radial glow behind the icon, fading to the flat background
              // toward the edges.
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.9,
                      colors: [
                        AppColors.splashBlobBright.withValues(alpha: 0.35),
                        fill,
                      ],
                    ),
                  ),
                ),
              ),
              // Large, brighter circle — top-left, cut off by the top and
              // left edges.
              Positioned(
                top: -height * 0.09,
                left: -width * 0.17,
                child: _Blob(
                  diameter: width * 0.63,
                  color: AppColors.splashBlobBright.withValues(alpha: 0.55),
                ),
              ),
              // Large, muted circle — bottom-right, cut off by the bottom
              // and right edges.
              Positioned(
                bottom: -height * 0.11,
                right: -width * 0.2,
                child: _Blob(
                  diameter: width * 0.82,
                  color: AppColors.splashBlobSmall.withValues(alpha: 0.4),
                ),
              ),
              // Faint concentric rings centered on the icon, echoing a pulse
              // rippling outward.
              for (final scale in [1.0, 1.55, 2.15])
                Positioned(
                  left: iconCenter.dx - (iconSize * scale) / 2,
                  top: iconCenter.dy - (iconSize * scale) / 2,
                  child: Container(
                    width: iconSize * scale,
                    height: iconSize * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                ),
              // Floating coral dot, unattached, above-right of the icon.
              Positioned(
                left: iconCenter.dx + iconSize * 0.42,
                top: iconCenter.dy - iconSize * 0.55,
                child: const _Dot(diameter: 11, color: AppColors.splashAccent),
              ),
              // Floating mint dot, lower-left, near the heartbeat trace.
              Positioned(
                left: width * 0.135,
                top: height * 0.655,
                child: _Dot(
                  diameter: 8,
                  color: AppColors.splashIconBackground.withValues(alpha: 0.8),
                ),
              ),
              // Horizontal heartbeat trace spanning the full width.
              Positioned(
                left: 0,
                right: 0,
                top: height * 0.66,
                child: SizedBox(
                  height: height * 0.075,
                  child: CustomPaint(
                    painter: _HeartbeatLinePainter(
                      color: Colors.white.withValues(alpha: 0.22),
                    ),
                    size: Size.infinite,
                  ),
                ),
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
                          child: CustomPaint(
                            painter: _PulsePainter(color: fill),
                          ),
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _TaglineDash(),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'Blood pressure, recorded',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          _TaglineDash(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: height * 0.09,
                child: Center(
                  child: SizedBox(
                    width: width * 0.33,
                    height: 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: const LinearProgressIndicator(
                        backgroundColor: AppColors.splashProgressTrack,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.splashAccent,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: height * 0.045,
                child: const Text(
                  'NOT A MEDICAL DEVICE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
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

class _Dot extends StatelessWidget {
  const _Dot({required this.diameter, required this.color});

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

/// The short horizontal dash flanking the tagline on either side.
class _TaglineDash extends StatelessWidget {
  const _TaglineDash();

  @override
  Widget build(BuildContext context) {
    return Container(width: 20, height: 1, color: Colors.white38);
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
  bool shouldRepaint(covariant _PulsePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Draws the full-width heartbeat trace near the bottom of the splash
/// screen — a mostly-flat line with two pulse spikes, matching the
/// reference. A separate, wider shape from [_PulsePainter]'s icon-sized
/// waveform.
class _HeartbeatLinePainter extends CustomPainter {
  const _HeartbeatLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final midY = size.height * 0.5;
    final path = Path()..moveTo(0, midY);

    void spikeAt(double startX) {
      path
        ..lineTo(startX, midY)
        ..lineTo(startX + w * 0.03, midY)
        ..lineTo(startX + w * 0.05, size.height * 0.1)
        ..lineTo(startX + w * 0.07, size.height * 0.95)
        ..lineTo(startX + w * 0.09, size.height * 0.35)
        ..lineTo(startX + w * 0.11, midY);
    }

    spikeAt(w * 0.18);
    path.lineTo(w * 0.55, midY);
    spikeAt(w * 0.55);
    path.lineTo(w, midY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HeartbeatLinePainter oldDelegate) =>
      oldDelegate.color != color;
}
