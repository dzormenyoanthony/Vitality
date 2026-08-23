import 'package:flutter/foundation.dart';
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
import '../../features/education/presentation/article_detail_screen.dart';
import '../../features/education/presentation/education_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/reminders/data/reminder.dart';
import '../../features/reminders/presentation/reminder_form_screen.dart';
import '../../features/reminders/presentation/reminders_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../constants/app_routes.dart';
import 'auth_gate_provider.dart';

/// Bridges Riverpod's [authGateProvider] to go_router's `refreshListenable`
/// so `redirect:` re-runs whenever auth/onboarding state changes, without
/// recreating the [GoRouter] instance (which would drop navigation state).
class _AuthGateRefreshListenable extends ChangeNotifier {
  _AuthGateRefreshListenable(Ref ref) {
    ref.listen(authGateProvider, (_, _) => notifyListeners());
  }
}

const _authRoutes = {
  AppRoutes.signIn,
  AppRoutes.signUp,
  AppRoutes.forgotPassword,
};

/// Centralized, named routing for Vitaly (PROJECT_SPEC.md §7, §30:
/// Authentication → Onboarding → Main application).
final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = _AuthGateRefreshListenable(ref);
  ref.onDispose(refreshListenable.dispose);

  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final gate = ref.read(authGateProvider);
      final location = state.matchedLocation;

      switch (gate) {
        case AuthGateLoading():
        case AuthGateError():
          return location == AppRoutes.splash ? null : AppRoutes.splash;
        case AuthGateUnauthenticated():
          return _authRoutes.contains(location) ? null : AppRoutes.signIn;
        case AuthGateNeedsOnboarding():
          return location == AppRoutes.onboarding ? null : AppRoutes.onboarding;
        case AuthGateReady():
          final mustLeave =
              _authRoutes.contains(location) ||
              location == AppRoutes.onboarding ||
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
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        name: AppRoutes.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: AppRoutes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.history,
        name: AppRoutes.history,
        builder: (context, state) => const HistoryScreen(),
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
        path: AppRoutes.trends,
        name: AppRoutes.trends,
        builder: (context, state) => const TrendsScreen(),
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
        path: AppRoutes.education,
        name: AppRoutes.education,
        builder: (context, state) => const EducationScreen(),
      ),
      GoRoute(
        path: AppRoutes.educationArticle,
        name: AppRoutes.educationArticle,
        builder: (context, state) => ArticleDetailScreen(
          articleId: state.pathParameters['id']!,
        ),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
