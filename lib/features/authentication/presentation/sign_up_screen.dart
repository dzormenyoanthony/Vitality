import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/errors/failure.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/credentials_validator.dart';
import 'auth_controllers.dart';

/// Visual design matches `design_references/Create Account screen.png`.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms and Privacy Policy first.'),
        ),
      );
      return;
    }
    ref
        .read(signUpControllerProvider.notifier)
        .signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final signUpState = ref.watch(signUpControllerProvider);
    final googleState = ref.watch(googleSignInControllerProvider);
    final isLoading = signUpState.isLoading || googleState.isLoading;

    return Scaffold(
      // White, not the hero's teal: SafeArea only insets the *content*, not
      // this background paint, so the system status/gesture bars sit
      // directly on this color. The reference keeps those areas clean —
      // the teal is confined to the hero header's own bounds below the
      // status bar, matching design_references/Create Account screen.png.
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _HeroHeader(),
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppSpacing.radiusXl),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.xxl,
                        AppSpacing.lg,
                        AppSpacing.lg,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OutlinedButton.icon(
                              onPressed: isLoading
                                  ? null
                                  : () => ref
                                        .read(
                                          googleSignInControllerProvider
                                              .notifier,
                                        )
                                        .signInWithGoogle(),
                              style: OutlinedButton.styleFrom(
                                shape: const StadiumBorder(),
                                side: BorderSide(
                                  color: theme.colorScheme.outline,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.md,
                                ),
                                foregroundColor: theme.colorScheme.onSurface,
                                // Solid white, not the sheet's faint mint
                                // tint: the bundled Google mark asset has
                                // its own opaque white square background,
                                // which otherwise shows up as a visible box
                                // against the tinted surface.
                                backgroundColor: Colors.white,
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
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
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
                                    'OR USE EMAIL',
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                          color: theme
                                              .colorScheme
                                              .onSurfaceVariant,
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
                              decoration: const InputDecoration(
                                labelText: 'EMAIL',
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                prefixIcon: Icon(Icons.mail_outline),
                              ),
                              validator: CredentialsValidator.validateEmail,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextFormField(
                              controller: _passwordController,
                              enabled: !isLoading,
                              obscureText: _obscurePassword,
                              autofillHints: const [AutofillHints.newPassword],
                              decoration: InputDecoration(
                                labelText: 'PASSWORD',
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                filled: true,
                                fillColor: AppColors.onboardingChipUnselected,
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
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextFormField(
                              controller: _confirmPasswordController,
                              enabled: !isLoading,
                              obscureText: _obscureConfirmPassword,
                              decoration: InputDecoration(
                                labelText: 'CONFIRM PASSWORD',
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                filled: true,
                                fillColor: AppColors.onboardingChipUnselected,
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  tooltip: _obscureConfirmPassword
                                      ? 'Show password'
                                      : 'Hide password',
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscureConfirmPassword =
                                        !_obscureConfirmPassword,
                                  ),
                                ),
                              ),
                              validator: (value) =>
                                  CredentialsValidator.validateConfirmPassword(
                                    value,
                                    _passwordController.text,
                                  ),
                              onFieldSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: _agreedToTerms,
                                  onChanged: isLoading
                                      ? null
                                      : (value) => setState(
                                          () => _agreedToTerms = value ?? false,
                                        ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      top: AppSpacing.sm,
                                    ),
                                    child: Text.rich(
                                      TextSpan(
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                        children: [
                                          const TextSpan(
                                            text: 'I agree to the ',
                                          ),
                                          TextSpan(
                                            text: 'Terms',
                                            style: TextStyle(
                                              color:
                                                  AppColors.dashboardAccentTeal,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const TextSpan(text: ' and '),
                                          TextSpan(
                                            text: 'Privacy Policy',
                                            style: TextStyle(
                                              color:
                                                  AppColors.dashboardAccentTeal,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          // Not linked anywhere yet — Vitaly has
                                          // no Terms/Privacy Policy document to
                                          // point to yet, so making these tap
                                          // targets would go nowhere.
                                          const TextSpan(
                                            text: '. Vitaly is not a medical device.',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            if (signUpState.hasError) ...[
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.sm,
                                ),
                                child: Text(
                                  friendlyMessage(signUpState.error!),
                                  style: TextStyle(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ),
                            ],
                            FilledButton.icon(
                              onPressed: isLoading ? null : _submit,
                              iconAlignment: IconAlignment.end,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.actionAccent,
                                foregroundColor: Colors.black,
                                shape: const StadiumBorder(),
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.md,
                                ),
                                textStyle: theme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              icon: signUpState.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.black,
                                    ),
                              label: const Text('Create account'),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Center(
                              child: TextButton(
                                onPressed: isLoading
                                    ? null
                                    : () => context.go(AppRoutes.signIn),
                                child: Text.rich(
                                  TextSpan(
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    children: [
                                      const TextSpan(text: 'Already with us? '),
                                      TextSpan(
                                        text: 'Sign in',
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
                  // Straddles the seam between the hero header and this
                  // sheet: painted after (on top of) both, with its shadow
                  // falling across the hero's teal and the Google button.
                  const Positioned(
                    top: -32,
                    right: AppSpacing.lg,
                    child: _ExampleReadingChip(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The dark teal header — brand mark and headline. The floating example
/// reading chip is anchored to the sheet below instead (see the `Stack`
/// around it in `SignUpScreen.build`), so it can straddle the seam and
/// paint on top of both the header and the sheet.
class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // The decorative circles are deliberately cropped at the hero box's
    // edges (matching the reference). Sized as fractions of width (not
    // fixed pixels) so their scale relative to the box matches the
    // reference across device sizes — same approach as
    // design_references/Splash.png's blobs.
    return ClipRect(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // Solid background, painted first. Positioned.fill (not a
              // bare Container) so it sizes to match the Stack instead
              // of trying to size itself under unbounded constraints —
              // the Stack's actual height is driven by the text content
              // below, its only non-positioned sizing child.
              const Positioned.fill(
                child: ColoredBox(color: AppColors.heroFill),
              ),
              // Decorative circles, painted over the background but
              // *behind* the text below — matching the reference, where
              // the headline stays fully legible even though the coral
              // circle's arc crosses behind it.
              Positioned(
                top: -width * 0.16,
                right: -width * 0.1,
                child: _Circle(
                  diameter: width * 0.46,
                  color: AppColors.dashboardAccentCoral,
                ),
              ),
              Positioned(
                top: width * 0.33,
                right: width * 0.03,
                child: _Circle(
                  diameter: width * 0.22,
                  color: AppColors.onboardingIllustrationCircleBright2,
                ),
              ),
              Positioned(
                top: width * 0.03,
                left: width * 0.2,
                child: Container(
                  width: width * 0.32,
                  height: width * 0.32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24),
                  ),
                ),
              ),
              // Text content, painted last so it's always on top.
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.splashIconBackground,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                          ),
                          child: const SizedBox(
                            width: 18,
                            height: 18,
                            child: CustomPaint(
                              painter: _PulsePainter(color: AppColors.heroFill),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'VITALY',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Start your blood pressure story',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Log a reading in nine seconds. Bring a real chart to your '
                      'next appointment.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
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

/// The same pulse-waveform mark used on `design_references/Splash.png`'s
/// icon badge (there via a private `_PulsePainter` in `splash_screen.dart`
/// that can't be imported, so it's duplicated here rather than shared
/// across screens). No built-in Material icon matches it —
/// `monitor_heart_outlined` also draws a heart outline the reference
/// doesn't have.
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

class _ExampleReadingChip extends StatelessWidget {
  const _ExampleReadingChip();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      elevation: 6,
      shadowColor: Colors.black,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.dashboardAccentTeal,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '118/76',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'TODAY 7:34',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The real official Google "G" mark, bundled as an asset by the
/// `sign_in_button` package (added specifically for this image — the
/// hand-painted arc approximation this replaced didn't read as the actual
/// logo).
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
