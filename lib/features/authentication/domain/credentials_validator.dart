/// Pure validation for sign-in/sign-up form fields (PROJECT_SPEC.md §7's
/// "distinguish input validation from medical/other conclusions" principle
/// applies generally: return an understandable message, nothing more).
///
/// Returns `null` when valid, or a user-facing error message when invalid —
/// matching Flutter's `FormField` validator convention so these compose
/// directly into `TextFormField.validator`.
abstract final class CredentialsValidator {
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Firebase Auth's own minimum password length; PROJECT_SPEC.md §20
  /// doesn't specify a stricter app-side policy.
  static const int minPasswordLength = 6;

  static String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your email address.';
    if (!_emailPattern.hasMatch(email)) return 'Enter a valid email address.';
    return null;
  }

  static String? validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Enter your password.';
    if (password.length < minPasswordLength) {
      return 'Password must be at least $minPasswordLength characters.';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    final confirmation = value ?? '';
    if (confirmation.isEmpty) return 'Confirm your password.';
    if (confirmation != password) return 'Passwords do not match.';
    return null;
  }

  static String? validatePreferredName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Enter a preferred name.';
    return null;
  }
}
