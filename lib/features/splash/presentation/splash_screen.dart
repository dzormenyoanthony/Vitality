import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/auth_gate_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/error_view.dart';
import '../../../l10n/app_localizations.dart';
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
///
/// The first frame is deliberately just the teal fill + the badge, matching
/// the native Android launch screen (see
/// `android/app/src/main/res/values-v31/styles.xml` and
/// `drawable/splash_badge.png`). The rest of the scene fades in over
/// [_introDuration] so the OS splash and this screen read as one continuous
/// splash rather than two: the badge is the fixed anchor across the handoff.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _introDuration = Duration(milliseconds: 550);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _introDuration,
  )..forward();

  // Background decoration settles first; foreground text/controls trail it
  // slightly so the scene builds outward from the badge.
  late final CurvedAnimation _backdrop = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.75, curve: Curves.easeOut),
  );
  late final CurvedAnimation _foreground = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.3, 1, curve: Curves.easeOut),
  );
  // The badge starts exactly where the native launch screen leaves it
  // (screen centre) and glides up to its resting position (matching
  // design_references/Splash.png) as the scene assembles - so the handoff
  // from the OS splash has no jump, and the composition still lands on the
  // mockup.
  late final CurvedAnimation _badgeSettle = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  /// Resting vertical centre of the badge, as a fraction of screen height —
  /// measured from `design_references/Splash.png` (badge centre y ≈ 0.474).
  static const _badgeCenterY = 0.474;

  /// How far below its resting position the badge starts, as a fraction of
  /// screen height: 0.5 (native splash centre) − [_badgeCenterY].
  static const _badgeSettleTravel = 0.5 - _badgeCenterY;

  @override
  void dispose() {
    _backdrop.dispose();
    _foreground.dispose();
    _badgeSettle.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
          // Rings and floating dots are anchored to the badge's resting
          // centre; they fade in as the badge arrives there.
          final iconCenter = Offset(width / 2, height * _badgeCenterY);

          return Stack(
            children: [
              // Radial glow behind the icon, fading to the flat background
              // toward the edges.
              Positioned.fill(
                child: FadeTransition(
                  opacity: _backdrop,
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
              ),
              // Large, brighter circle — top-left, cut off by the top and
              // left edges.
              Positioned(
                top: -height * 0.09,
                left: -width * 0.17,
                child: FadeTransition(
                  opacity: _backdrop,
                  child: _Blob(
                    diameter: width * 0.63,
                    color: AppColors.splashBlobBright.withValues(alpha: 0.55),
                  ),
                ),
              ),
              // Large, muted circle — bottom-right, cut off by the bottom
              // and right edges.
              Positioned(
                bottom: -height * 0.11,
                right: -width * 0.2,
                child: FadeTransition(
                  opacity: _backdrop,
                  child: _Blob(
                    diameter: width * 0.82,
                    color: AppColors.splashBlobSmall.withValues(alpha: 0.4),
                  ),
                ),
              ),
              // Faint concentric rings centered on the icon, echoing a pulse
              // rippling outward.
              for (final scale in [1.0, 1.55, 2.15])
                Positioned(
                  left: iconCenter.dx - (iconSize * scale) / 2,
                  top: iconCenter.dy - (iconSize * scale) / 2,
                  child: FadeTransition(
                    opacity: _backdrop,
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
                ),
              // Floating coral dot, unattached, above-right of the icon.
              Positioned(
                left: iconCenter.dx + iconSize * 0.42,
                top: iconCenter.dy - iconSize * 0.55,
                child: FadeTransition(
                  opacity: _backdrop,
                  child: const _Dot(
                    diameter: 11,
                    color: AppColors.splashAccent,
                  ),
                ),
              ),
              // Floating mint dot, lower-left, near the heartbeat trace.
              Positioned(
                left: width * 0.135,
                top: height * 0.695,
                child: FadeTransition(
                  opacity: _backdrop,
                  child: _Dot(
                    diameter: 8,
                    color: AppColors.splashIconBackground.withValues(alpha: 0.8),
                  ),
                ),
              ),
              // Horizontal heartbeat trace spanning the full width.
              Positioned(
                left: 0,
                right: 0,
                top: height * 0.70,
                child: FadeTransition(
                  opacity: _backdrop,
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
              ),
              // The badge renders immediately at full opacity. It starts at
              // screen centre — exactly where the native launch screen left
              // it (no jump) — and glides up to its resting position as the
              // scene assembles.
              Positioned(
                top: height * _badgeCenterY - iconSize / 2,
                left: (width - iconSize) / 2,
                child: AnimatedBuilder(
                  animation: _badgeSettle,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(
                      0,
                      (1 - _badgeSettle.value) *
                          height *
                          _badgeSettleTravel,
                    ),
                    child: child,
                  ),
                  child: Container(
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
                ),
              ),
              // Wordmark + tagline, pinned just below the badge's resting
              // position and faded in with the rest of the scene.
              Positioned(
                top: height * _badgeCenterY + iconSize / 2 + height * 0.035,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _foreground,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            l10n.splashWordmark,
                            style: const TextStyle(
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
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              l10n.splashTagline,
                              style: const TextStyle(
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
                child: FadeTransition(
                  opacity: _foreground,
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
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: height * 0.045,
                child: FadeTransition(
                  opacity: _foreground,
                  child: Text(
                    l10n.splashNotAMedicalDevice,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
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
