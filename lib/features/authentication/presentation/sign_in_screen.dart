import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/errors/failure.dart';
import '../../../core/theme/app_colors.dart';
import '../data/keep_signed_in_provider.dart';
import '../domain/credentials_validator.dart';
import 'auth_controllers.dart';

/// Visual design matches `design_references/Sign In screen.png`, including
/// its "Welcome back, Anna" reading-summary card and avatar — per explicit
/// user direction, those are static illustrative content (like the example
/// reading chip on the Create Account screen), not a real signed-in user's
/// data. Real per-user history isn't available here anyway: local
/// blood-pressure/reminder data is wiped on sign-out (see main.dart's
/// `_handleAuthGateChange`), so nothing genuine could be shown pre-auth.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(signInControllerProvider.notifier)
        .signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final signInState = ref.watch(signInControllerProvider);
    final googleState = ref.watch(googleSignInControllerProvider);
    final keepSignedIn = ref.watch(keepSignedInProvider);
    final isLoading = signInState.isLoading || googleState.isLoading;

    return Scaffold(
      // White, not the hero's mint: SafeArea only insets the *content*, not
      // this background paint, so the system status/gesture bars sit
      // directly on this color instead of showing the hero tint behind them.
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _HeroBanner(),
            Expanded(
              child: ColoredBox(
                // The hero card has its own rounded bottom corners (see
                // _HeroBanner) and sits on top of this same plain white
                // page — unlike Create Account, there's no separate rounded
                // "sheet" here.
                color: theme.colorScheme.surface,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Welcome back',
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Sign in to continue tracking your blood pressure.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        OutlinedButton.icon(
                          onPressed: isLoading
                              ? null
                              : () => ref
                                    .read(
                                      googleSignInControllerProvider.notifier,
                                    )
                                    .signInWithGoogle(),
                          style: OutlinedButton.styleFrom(
                            shape: const StadiumBorder(),
                            side: BorderSide(
                              color: theme.colorScheme.outline,
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            foregroundColor: theme.colorScheme.onSurface,
                            // Solid white, not the sheet's tint: the bundled
                            // Google mark asset has its own opaque white
                            // square background, which otherwise shows up
                            // as a visible box against a tinted surface.
                            backgroundColor: Colors.white,
                            // No press/hover/focus overlay: a grey tap
                            // ripple over solid white contrasts badly
                            // against the Google mark's own opaque white
                            // square background.
                            overlayColor: Colors.transparent,
                          ),
                          icon: googleState.isLoading
                              ? const SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const _GoogleLogo(),
                          label: Text(
                            'Continue with Google',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (googleState.hasError) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            friendlyMessage(googleState.error!),
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: theme.colorScheme.outlineVariant,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                              ),
                              child: Text(
                                'OR',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: theme.colorScheme.outlineVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        TextFormField(
                          controller: _emailController,
                          enabled: !isLoading,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          decoration: InputDecoration(
                            labelText: 'EMAIL',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            filled: true,
                            fillColor: AppColors.onboardingChipUnselected,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                              borderSide: const BorderSide(
                                color: AppColors.dashboardAccentTeal,
                                width: 2,
                              ),
                            ),
                            prefixIcon: const Icon(Icons.mail_outline),
                          ),
                          validator: CredentialsValidator.validateEmail,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _passwordController,
                          enabled: !isLoading,
                          obscureText: _obscurePassword,
                          autofillHints: const [AutofillHints.password],
                          decoration: InputDecoration(
                            labelText: 'PASSWORD',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelStyle: const TextStyle(
                              color: AppColors.dashboardAccentTeal,
                            ),
                            floatingLabelStyle: const TextStyle(
                              color: AppColors.dashboardAccentTeal,
                            ),
                            prefixIconColor: AppColors.dashboardAccentTeal,
                            suffixIconColor: AppColors.dashboardAccentTeal,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                              borderSide: const BorderSide(
                                color: AppColors.dashboardAccentTeal,
                                width: 2,
                              ),
                            ),
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              tooltip: _obscurePassword
                                  ? 'Show password'
                                  : 'Hide password',
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                          validator: CredentialsValidator.validatePassword,
                          onFieldSubmitted: (_) => _submit(),
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: keepSignedIn,
                              onChanged: isLoading
                                  ? null
                                  : (value) => ref
                                        .read(keepSignedInProvider.notifier)
                                        .setKeepSignedIn(value ?? true),
                            ),
                            Expanded(
                              child: Text(
                                'Keep me signed in',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                            TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () => context.go(AppRoutes.forgotPassword),
                              child: const Text(
                                'Forgot?',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        if (signInState.hasError) ...[
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: Text(
                              friendlyMessage(signInState.error!),
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.sm),
                        FilledButton.icon(
                          onPressed: isLoading ? null : _submit,
                          iconAlignment: IconAlignment.end,
                          style: FilledButton.styleFrom(
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            textStyle: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          icon: signInState.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.arrow_forward),
                          label: const Text('Sign in'),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Center(
                          child: TextButton(
                            onPressed: isLoading
                                ? null
                                : () => context.go(AppRoutes.signUp),
                            child: Text.rich(
                              TextSpan(
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                children: [
                                  const TextSpan(text: 'New here? '),
                                  TextSpan(
                                    text: 'Create an account',
                                    style: TextStyle(
                                      color: AppColors.dashboardAccentTeal,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The pale mint header — brand mark, decorative shapes, and the mock
/// reading-summary card + avatar. See the file-level doc comment on
/// [SignInScreen] for why the card/avatar are static illustrative content.
class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(width * 0.22),
            bottomRight: Radius.circular(width * 0.06),
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              const Positioned.fill(
                child: ColoredBox(color: AppColors.onboardingIllustrationBg),
              ),
              // Decorative circle, cropped at the header's top-right edge —
              // matching the reference's pale shape behind the avatar.
              Positioned(
                top: -width * 0.12,
                right: -width * 0.18,
                child: _Circle(
                  diameter: width * 0.68,
                  color: AppColors.onboardingIllustrationCircleBright,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.heroFill,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                          ),
                          child: const SizedBox(
                            width: 18,
                            height: 18,
                            child: CustomPaint(
                              painter: _PulsePainter(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'VITALY',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.heroFill,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(child: _ReadingSummaryCard()),
                        const SizedBox(width: 40),
                        const Padding(
                          padding: EdgeInsets.only(top: AppSpacing.md),
                          child: _AvatarBadge(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Static "7-day average" card, mirroring the reference's illustrative
/// example — not a real user's reading history (see [SignInScreen]'s doc
/// comment).
class _ReadingSummaryCard extends StatelessWidget {
  const _ReadingSummaryCard();

  static const _spots = [
    FlSpot(0, 2),
    FlSpot(1, 3.2),
    FlSpot(2, 1.8),
    FlSpot(3, 3.4),
    FlSpot(4, 2.6),
    FlSpot(5, 3.8),
    FlSpot(6, 4.2),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      elevation: 2,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '7-DAY AVERAGE',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Text(
                  '42 logs',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.dashboardAccentTeal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text.rich(
              TextSpan(
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                children: [
                  const TextSpan(text: '121'),
                  TextSpan(
                    text: '/78',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 36,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 5,
                  titlesData: const FlTitlesData(show: false),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  lineTouchData: const LineTouchData(enabled: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _spots,
                      color: AppColors.dashboardAccentTeal,
                      barWidth: 2,
                      isCurved: false,
                      dotData: FlDotData(
                        show: true,
                        checkToShowDot: (spot, barData) =>
                            spot.x == barData.spots.last.x,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                              radius: 4,
                              color: AppColors.dashboardAccentCoral,
                              strokeWidth: 0,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Static avatar + join-month, mirroring the reference's illustrative
/// example — not a real signed-in user (see [SignInScreen]'s doc comment).
class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            'A',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppColors.heroFill,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'SINCE MAR',
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.heroFill,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.diameter, required this.color});

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

/// The same pulse-waveform mark used on the Splash and Create Account
/// screens (each keeps its own private copy — see sign_up_screen.dart's
/// `_PulsePainter` doc comment for why it isn't shared).
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

/// The real official Google "G" mark, bundled as an asset by the
/// `sign_in_button` package (same asset as Create Account's `_GoogleLogo`;
/// duplicated here rather than shared since it's a private class there).
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return const Image(
      image: AssetImage(
        'assets/logos/google_light.png',
        package: 'sign_in_button',
      ),
      width: 32,
      height: 32,
    );
  }
}
