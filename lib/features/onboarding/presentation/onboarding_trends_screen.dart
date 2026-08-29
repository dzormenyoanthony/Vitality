import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/onboarding_progress_dots.dart';
import '../../../l10n/app_localizations.dart';

/// Second step of the onboarding carousel ("Onboarding 2 of 3" in
/// `design_references/`) — introduces the Trends view before the user
/// starts using Vitaly (PROJECT_SPEC.md §19).
///
/// Visual design matches `design_references/Onboarding 2 of 3.png`: a
/// peach illustration card with decorative circles containing a mock
/// 30-day trend chart, a "TRENDS" eyebrow badge, a bold headline, body
/// copy, a step-progress indicator, and a "Next" action. Both "Skip" and
/// "Next" call [onContinue] — this screen doesn't distinguish them
/// functionally, matching Onboarding 1 of 3's pattern.
class OnboardingTrendsScreen extends StatelessWidget {
  const OnboardingTrendsScreen({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onContinue,
                    child: Text(
                      l10n.onboardingSkip,
                      style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const AspectRatio(aspectRatio: 694 / 942, child: _TrendsIllustration()),
                const SizedBox(height: AppSpacing.lg),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.onboardingCoral,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      l10n.onboardingTrendsBadge,
                      style: theme.textTheme.labelMedium?.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.onboardingTrendsTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppColors.onboardingHeadline2,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.onboardingTrendsBody,
                  style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.onboardingBody2),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
          child: Row(
            children: [
              const OnboardingProgressDots(
                total: 3,
                activeIndex: 1,
                activeColor: AppColors.onboardingCoral,
                inactiveColor: AppColors.onboardingDotInactive,
              ),
              const Spacer(),
              FilledButton(
                onPressed: onContinue,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.onboardingCoral,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.onboardingNext, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(width: AppSpacing.sm),
                    const Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The peach illustration card with its two decorative circles, the
/// centered mock trend-chart card, and the floating "days logged" badge —
/// purely decorative, not an interactive preview of the real Trends
/// screen.
class _TrendsIllustration extends StatelessWidget {
  const _TrendsIllustration();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: ColoredBox(
        color: AppColors.onboardingIllustrationBg2,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            return Stack(
              children: [
                Positioned(
                  top: -height * 0.04,
                  left: -width * 0.08,
                  child: _Blob(diameter: width * 0.42, color: AppColors.onboardingIllustrationCircleBright2),
                ),
                Positioned(
                  bottom: -height * 0.04,
                  right: -width * 0.08,
                  child: _Blob(diameter: width * 0.34, color: AppColors.onboardingIllustrationCircleMuted2),
                ),
                Align(
                  alignment: const Alignment(0, -0.28),
                  child: FractionallySizedBox(widthFactor: 0.706, child: _MockChartCard()),
                ),
                Positioned(
                  left: width * 0.063,
                  bottom: height * 0.046,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                    child: Text(
                      AppLocalizations.of(context).onboardingTrendsMockDaysLogged,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onboardingHeadline2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
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

/// A small non-interactive mockup of the Trends chart, used only as
/// onboarding illustration content.
class _MockChartCard extends StatelessWidget {
  const _MockChartCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.082, vertical: width * 0.06),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      l10n.onboardingTrendsMockRange,
                      style: theme.textTheme.labelMedium?.copyWith(color: AppColors.onboardingAccent),
                    ),
                    const Spacer(),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          '133 / 85',
                          style: TextStyle(
                            color: AppColors.onboardingHeadline2,
                            fontSize: width * 0.068,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: width * 0.05),
                AspectRatio(
                  aspectRatio: 2.7,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.onboardingChartFill,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const CustomPaint(painter: _TrendChartPainter(), size: Size.infinite),
                  ),
                ),
                SizedBox(height: width * 0.045),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      _LegendSwatch(dashed: false, color: AppColors.onboardingAccent),
                      SizedBox(width: width * 0.02),
                      Text(
                        l10n.onboardingTrendsMockSystolic,
                        style: theme.textTheme.bodySmall?.copyWith(color: AppColors.onboardingAccent),
                      ),
                      SizedBox(width: width * 0.05),
                      _LegendSwatch(dashed: true, color: AppColors.onboardingDiastolicLine),
                      SizedBox(width: width * 0.02),
                      Text(
                        l10n.onboardingTrendsMockDiastolic,
                        style: theme.textTheme.bodySmall?.copyWith(color: AppColors.onboardingDiastolicLine),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LegendSwatch extends StatelessWidget {
  const _LegendSwatch({required this.dashed, required this.color});

  final bool dashed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14,
      height: 8,
      child: CustomPaint(painter: _LegendLinePainter(dashed: dashed, color: color)),
    );
  }
}

class _LegendLinePainter extends CustomPainter {
  const _LegendLinePainter({required this.dashed, required this.color});

  final bool dashed;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final y = size.height / 2;
    if (!dashed) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      return;
    }
    const dashWidth = 3.0;
    const gap = 2.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset((x + dashWidth).clamp(0, size.width), y), paint);
      x += dashWidth + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _LegendLinePainter oldDelegate) =>
      oldDelegate.dashed != dashed || oldDelegate.color != color;
}

/// Draws a stylized 30-day systolic/diastolic trend — a decorative
/// illustration, not real data (matches
/// `design_references/Onboarding 2 of 3.png`).
class _TrendChartPainter extends CustomPainter {
  const _TrendChartPainter();

  static const _systolicFracs = [0.35, 0.55, 0.25, 0.50, 0.15, 0.30, 0.10];
  static const _diastolicFracs = [0.75, 0.85, 0.70, 0.80, 0.65, 0.72, 0.68];

  List<Offset> _points(Size size, List<double> fracs) {
    final n = fracs.length;
    return List.generate(n, (i) {
      final x = size.width * i / (n - 1);
      final y = size.height * fracs[i];
      return Offset(x, y);
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    final systolic = _points(size, _systolicFracs);
    final diastolic = _points(size, _diastolicFracs);

    final fillPath = Path()..moveTo(systolic.first.dx, systolic.first.dy);
    for (final p in systolic.skip(1)) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(fillPath, Paint()..color = AppColors.onboardingAccent.withValues(alpha: 0.08));

    final systolicPaint = Paint()
      ..color = AppColors.onboardingAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.045
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final systolicPath = Path()..moveTo(systolic.first.dx, systolic.first.dy);
    for (final p in systolic.skip(1)) {
      systolicPath.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(systolicPath, systolicPaint);
    canvas.drawCircle(systolic.last, size.height * 0.06, Paint()..color = AppColors.onboardingAccent);

    final diastolicPaint = Paint()
      ..color = AppColors.onboardingDiastolicLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.035
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < diastolic.length - 1; i++) {
      final a = diastolic[i];
      final b = diastolic[i + 1];
      final segment = b - a;
      final length = segment.distance;
      const dash = 8.0;
      const gap = 6.0;
      var travelled = 0.0;
      while (travelled < length) {
        final start = a + segment * (travelled / length);
        final endT = ((travelled + dash) / length).clamp(0.0, 1.0);
        final end = a + segment * endT;
        canvas.drawLine(start, end, diastolicPaint);
        travelled += dash + gap;
      }
    }
    canvas.drawCircle(diastolic.last, size.height * 0.05, Paint()..color = AppColors.onboardingDiastolicLine);
  }

  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) => false;
}
