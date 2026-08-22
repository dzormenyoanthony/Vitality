/// Minimal typed representation of an authenticated Vitaly user.
///
/// Deliberately excludes anything beyond identity — profile data (preferred
/// name, onboarding status) lives in the onboarding feature's
/// `UserProfileRepository`, not here.
final class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.emailVerified,
  });

  final String uid;
  final String? email;
  final bool emailVerified;
}
