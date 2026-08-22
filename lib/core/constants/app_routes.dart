/// Centralized named route paths.
///
/// All navigation must reference these constants rather than string
/// literals (PROJECT_SPEC.md §7: "routes should be named clearly").
abstract final class AppRoutes {
  static const String splash = '/';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';
  static const String onboarding = '/onboarding';
  static const String dashboard = '/dashboard';
  static const String history = '/history';
  static const String recordBp = '/record-bp';
  static const String readingDetail = '/reading/:id';
  static const String trends = '/trends';
  static const String reminders = '/reminders';
  static const String reminderForm = '/reminder-form';

  static String readingDetailPath(int id) => '/reading/$id';
}
