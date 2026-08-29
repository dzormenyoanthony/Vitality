import '../../../l10n/app_localizations.dart';

/// Pure validation for sign-in/sign-up form fields (PROJECT_SPEC.md §7's
/// "distinguish input validation from medical/other conclusions" principle
/// applies generally: return an understandable message, nothing more).
///
/// Returns `null` when valid, or a user-facing error message when invalid —
/// matching Flutter's `FormField` validator convention so these compose
/// into `TextFormField.validator` via a closure that supplies [l10n].
abstract final class CredentialsValidator {
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Firebase Auth's own minimum password length; PROJECT_SPEC.md §20
  /// doesn't specify a stricter app-side policy.
  static const int minPasswordLength = 6;

  static String? validateEmail(AppLocalizations l10n, String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return l10n.validationEmailRequired;
    if (!_emailPattern.hasMatch(email)) return l10n.validationEmailInvalid;
    return null;
  }

  static String? validatePassword(AppLocalizations l10n, String? value) {
    final password = value ?? '';
    if (password.isEmpty) return l10n.validationPasswordRequired;
    if (password.length < minPasswordLength) {
      return l10n.validationPasswordTooShort(minPasswordLength);
    }
    return null;
  }

  static String? validateConfirmPassword(
    AppLocalizations l10n,
    String? value,
    String password,
  ) {
    final confirmation = value ?? '';
    if (confirmation.isEmpty) return l10n.validationConfirmPasswordRequired;
    if (confirmation != password) return l10n.validationPasswordsDoNotMatch;
    return null;
  }

  static String? validatePreferredName(AppLocalizations l10n, String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return l10n.validationPreferredNameRequired;
    return null;
  }
}
