/// A user's Vitaly profile document (PROJECT_SPEC.md §21: "user profiles").
///
/// Deliberately excludes age/sex/height/weight/medical history — §19
/// forbids collecting those merely to create an account.
final class UserProfile {
  const UserProfile({required this.displayName, required this.onboardingCompleted});

  final String displayName;
  final bool onboardingCompleted;
}
