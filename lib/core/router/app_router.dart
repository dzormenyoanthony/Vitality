import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/presentation/forgot_password_screen.dart';
import '../../features/authentication/presentation/sign_in_screen.dart';
import '../../features/authentication/presentation/sign_up_screen.dart';
import '../../features/blood_pressure/data/blood_pressure_reading.dart';
import '../../features/blood_pressure/presentation/history_screen.dart';
import '../../features/blood_pressure/presentation/reading_detail_screen.dart';
import '../../features/blood_pressure/presentation/record_bp_screen.dart';
import '../../features/blood_pressure/presentation/trends_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/data_export/presentation/export_data_screen.dart';
import '../../features/education/presentation/article_detail_screen.dart';
import '../../features/education/presentation/education_screen.dart';
import '../../features/onboarding/data/onboarding_intro_provider.dart';
import '../../features/onboarding/presentation/onboarding_complete_profile_screen.dart';
import '../../features/onboarding/presentation/onboarding_controller.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/reminders/data/reminder.dart';
import '../../features/reminders/presentation/reminder_form_screen.dart';
import '../../features/reminders/presentation/reminders_screen.dart';
import '../../features/reports/presentation/report_viewer_screen.dart';
import '../../features/reports/presentation/review_extracted_screen.dart';
import '../../features/reports/presentation/saved_reports_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../constants/app_routes.dart';
import '../theme/app_theme.dart';
import '../widgets/main_shell.dart';
import 'auth_gate_provider.dart';
import 'splash_min_duration_provider.dart';

/// Locks a route's entire subtree to the light theme regardless of the
/// user's theme preference (system/light/dark). Applied to the whole
/// pre-auth flow — onboarding, name collection, sign up, sign in, forgot
/// password — per explicit product direction: those screens are a fixed
/// brand moment and must never render in dark mode, even when the rest of
/// the app (from Dashboard onward) follows [themeModeProvider] normally.
Widget _lightLocked(Widget child) => Theme(data: AppTheme.light(), child: child);

/// Bridges Riverpod's [authGateProvider] and [splashMinDurationElapsedProvider]
/// to go_router's `refreshListenable` so `redirect:` re-runs whenever
/// auth/onboarding state changes (or the minimum Splash duration elapses),
/// without recreating the [GoRouter] instance (which would drop navigation
/// state).
class _AuthGateRefreshListenable extends ChangeNotifier {
  _AuthGateRefreshListenable(Ref ref) {
    ref.listen(authGateProvider, (_, _) => notifyListeners());
    ref.listen(splashMinDurationElapsedProvider, (_, _) => notifyListeners());
    ref.listen(pendingProfileNameProvider, (_, _) => notifyListeners());
  }
}

const _authRoutes = {
  AppRoutes.signIn,
  AppRoutes.signUp,
  AppRoutes.forgotPassword,
};

// Reachable by a brand-new, unauthenticated visitor on a device that has
// never finished onboarding: the intro carousel itself, plus every auth
// route as an escape hatch (e.g. "Already with us? Sign in" from Create
// Account, for someone who actually has an account already).
const _preAuthOnboardingRoutes = {
  AppRoutes.onboarding,
  ..._authRoutes,
};

/// Centralized, named routing for Vitaly (PROJECT_SPEC.md §7, §30: for a
/// brand-new user, Onboarding → Authentication → Main application; a
/// returning user who's simply signed out skips straight to Authentication).
final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = _AuthGateRefreshListenable(ref);
  ref.onDispose(refreshListenable.dispose);

  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final gate = ref.read(authGateProvider);
      final location = state.matchedLocation;

      // Keep the branded Splash screen on screen for a minimum, perceptible
      // duration regardless of how fast the auth/onboarding gate resolves
      // (see splash_min_duration_provider.dart).
      if (!ref.read(splashMinDurationElapsedProvider)) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }

      // Every sign-in/sign-up briefly re-triggers AuthGateLoading: watching
      // userProfileStreamProvider(uid) for the first time after a fresh
      // authStateChanges() emission is synchronously Loading until that
      // stream's first event arrives, however fast that is in practice.
      // Splash's own minimum-duration window above already covers this at
      // boot (initialLocation is `/`, and gate starts Loading there), so
      // Loading never needs to force navigation anywhere - doing so is
      // exactly what used to bounce a user mid-flow (e.g. sitting on
      // `/sign-in` or `/sign-up`, showing its own loading indicator) back
      // to Splash for a single frame before the gate resolves further.
      // Staying put lets the current screen's own loading state carry it
      // instead.
      //
      // NeedsOnboarding needs one exception to that same principle: right
      // after the pre-auth onboarding carousel hands a collected name to
      // Create Account, SignUpController.signUp() creates the Firebase Auth
      // user first and only writes the Firestore profile afterward - a real
      // async gap in which the gate legitimately reports NeedsOnboarding
      // before that write lands. Without this guard the redirect below
      // would bounce the user to the name-collection screen while still
      // sitting on `/sign-up` waiting on that same write.
      // pendingProfileNameProvider is only non-null during that exact
      // window (cleared right after the write succeeds), so it's a
      // reliable signal to stay put instead.
      final signUpInFlight = ref.read(pendingProfileNameProvider) != null;

      switch (gate) {
        case AuthGateLoading():
          return null;
        case AuthGateError():
          return location == AppRoutes.splash ? null : AppRoutes.splash;
        case AuthGateUnauthenticated():
          final introSeen = ref.read(onboardingIntroSeenProvider);
          if (!introSeen) {
            return _preAuthOnboardingRoutes.contains(location)
                ? null
                : AppRoutes.onboarding;
          }
          return _authRoutes.contains(location) ? null : AppRoutes.signIn;
        case AuthGateNeedsOnboarding():
          if (signUpInFlight) return null;
          return location == AppRoutes.onboardingProfile
              ? null
              : AppRoutes.onboardingProfile;
        case AuthGateReady():
          final mustLeave =
              _authRoutes.contains(location) ||
              location == AppRoutes.onboarding ||
              location == AppRoutes.onboardingProfile ||
              location == AppRoutes.splash;
          return mustLeave ? AppRoutes.dashboard : null;
      }
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        name: AppRoutes.signIn,
        builder: (context, state) => _lightLocked(const SignInScreen()),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        name: AppRoutes.signUp,
        builder: (context, state) => _lightLocked(const SignUpScreen()),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: AppRoutes.forgotPassword,
        builder: (context, state) => _lightLocked(const ForgotPasswordScreen()),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: AppRoutes.onboarding,
        builder: (context, state) => _lightLocked(const OnboardingScreen()),
      ),
      GoRoute(
        path: AppRoutes.onboardingProfile,
        name: AppRoutes.onboardingProfile,
        builder: (context, state) =>
            _lightLocked(const OnboardingCompleteProfileScreen()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                name: AppRoutes.dashboard,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.history,
                name: AppRoutes.history,
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.trends,
                name: AppRoutes.trends,
                builder: (context, state) => const TrendsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.education,
                name: AppRoutes.education,
                builder: (context, state) => const EducationScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.recordBp,
        name: AppRoutes.recordBp,
        builder: (context, state) => RecordBpScreen(
          existingReading: state.extra as BloodPressureReading?,
        ),
      ),
      GoRoute(
        path: AppRoutes.readingDetail,
        name: AppRoutes.readingDetail,
        builder: (context, state) => ReadingDetailScreen(
          readingId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.reminders,
        name: AppRoutes.reminders,
        builder: (context, state) => const RemindersScreen(),
      ),
      GoRoute(
        path: AppRoutes.reminderForm,
        name: AppRoutes.reminderForm,
        builder: (context, state) => ReminderFormScreen(
          existingReminder: state.extra as Reminder?,
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.exportData,
        name: AppRoutes.exportData,
        builder: (context, state) => const ExportDataScreen(),
      ),
      GoRoute(
        path: AppRoutes.educationArticle,
        name: AppRoutes.educationArticle,
        builder: (context, state) => ArticleDetailScreen(
          articleId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.reviewExtracted,
        name: AppRoutes.reviewExtracted,
        builder: (context, state) => ReviewExtractedScreen(
          args: state.extra as ReviewExtractedArgs,
        ),
      ),
      GoRoute(
        path: AppRoutes.savedReports,
        name: AppRoutes.savedReports,
        builder: (context, state) => const SavedReportsScreen(),
      ),
      GoRoute(
        path: AppRoutes.reportViewer,
        name: AppRoutes.reportViewer,
        builder: (context, state) => ReportViewerScreen(
          reportId: int.parse(state.pathParameters['id']!),
        ),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
