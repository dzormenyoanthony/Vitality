// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Vitaly';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonClose => 'Close';

  @override
  String get commonTryAgain => 'Try again';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonBack => 'Back';

  @override
  String get navHome => 'Home';

  @override
  String get navHistory => 'History';

  @override
  String get navTrends => 'Trends';

  @override
  String get navLearn => 'Learn';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get authDividerOr => 'OR';

  @override
  String get authDividerOrUseEmail => 'OR USE EMAIL';

  @override
  String get authEmailFieldLabel => 'EMAIL';

  @override
  String get authPasswordFieldLabel => 'PASSWORD';

  @override
  String get authConfirmPasswordFieldLabel => 'CONFIRM PASSWORD';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get signInTitle => 'Welcome back';

  @override
  String get signInSubtitle =>
      'Sign in to continue tracking your blood pressure.';

  @override
  String get signInKeepSignedIn => 'Keep me signed in';

  @override
  String get signInForgot => 'Forgot?';

  @override
  String get signInSubmit => 'Sign in';

  @override
  String get signInNoAccountPrompt => 'New here? ';

  @override
  String get signInCreateAccountAction => 'Create an account';

  @override
  String get signInMockSevenDayAverage => '7-DAY AVERAGE';

  @override
  String get signInMockLogCount => '42 logs';

  @override
  String get signInMockAvatarInitial => 'A';

  @override
  String get signInMockSince => 'SINCE MAR';

  @override
  String get signUpAgreeToTermsError =>
      'Please agree to the Terms and Privacy Policy first.';

  @override
  String get signUpHeroTitle => 'Start your blood pressure story';

  @override
  String get signUpHeroSubtitle =>
      'Log a reading in nine seconds. Bring a real chart to your next appointment.';

  @override
  String get signUpAgreePrefix => 'I agree to the ';

  @override
  String get signUpTermsLink => 'Terms';

  @override
  String get signUpAgreeConjunction => ' and ';

  @override
  String get signUpPrivacyLink => 'Privacy Policy';

  @override
  String get signUpAgreeSuffix => '. Vitaly is not a medical device.';

  @override
  String get signUpSubmit => 'Create account';

  @override
  String get signUpHasAccountPrompt => 'Already with us? ';

  @override
  String get signUpSignInAction => 'Sign in';

  @override
  String get signUpExampleReadingTime => 'TODAY 7:34';

  @override
  String get forgotPasswordAppBarTitle => 'Reset password';

  @override
  String get forgotPasswordTitle => 'Reset your password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your account\'s email and we\'ll send you a reset link.';

  @override
  String get forgotPasswordEmailLabel => 'Email';

  @override
  String get forgotPasswordSubmit => 'Send reset link';

  @override
  String get forgotPasswordSentBody =>
      'If an account exists for that email, a reset link is on its way. Check your inbox.';

  @override
  String get startupFailureMessage =>
      'Vitaly couldn\'t start. Please try again shortly.';

  @override
  String get splashWordmark => 'VITALY';

  @override
  String get splashTagline => 'Blood pressure, recorded';

  @override
  String get splashNotAMedicalDevice => 'NOT A MEDICAL DEVICE';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionProfile => 'PROFILE';

  @override
  String get settingsSectionAppearance => 'APPEARANCE';

  @override
  String get settingsSectionData => 'DATA';

  @override
  String get settingsSectionAccount => 'ACCOUNT';

  @override
  String get settingsManageReminders => 'Manage reminders';

  @override
  String get settingsPreferredNameLabel => 'Preferred name';

  @override
  String get settingsSaveNameTooltip => 'Save name';

  @override
  String get settingsEmailLabel => 'Email';

  @override
  String get settingsEmailCaption =>
      'Used for sign-in and export receipts only. Readings stay on this device.';

  @override
  String get settingsThemeOptionSystem => 'System';

  @override
  String get settingsThemeOptionLight => 'Light';

  @override
  String get settingsThemeOptionDark => 'Dark';

  @override
  String settingsThemeHelperSystem(String brightness) {
    return 'System follows your Android theme, currently $brightness.';
  }

  @override
  String get settingsThemeHelperLight => 'Using light theme.';

  @override
  String get settingsThemeHelperDark => 'Using dark theme.';

  @override
  String get settingsBrightnessDark => 'dark';

  @override
  String get settingsBrightnessLight => 'light';

  @override
  String get settingsLargerNumbersTitle => 'Larger numbers';

  @override
  String get settingsLargerNumbersSubtitle =>
      'Increase the size of reading values';

  @override
  String get settingsSavedReportsTitle => 'Saved reports';

  @override
  String get settingsSavedReportsSubtitle => 'Scanned or imported BP reports';

  @override
  String get settingsExportDataTitle => 'Export data';

  @override
  String get settingsExportDataSubtitle =>
      'BP readings (CSV) and saved report files, as a ZIP';

  @override
  String get settingsExportMissingTitle => 'Some report files are unavailable';

  @override
  String settingsExportMissingBody(String files) {
    return 'These report files couldn\'t be found on this device and will be left out of the export:\n\n$files\n\nThe rest of your export will still be included. Continue?';
  }

  @override
  String get settingsExportFailed =>
      'Couldn\'t prepare your export. Please try again.';

  @override
  String get settingsDeleteAccountTitle => 'Delete your account?';

  @override
  String get settingsDeleteAccountBody =>
      'This permanently deletes your account and all locally stored blood pressure data and reminders. This cannot be undone.';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsDeleteAccount => 'Delete account';

  @override
  String get settingsDeleteAccountCaption =>
      'Deleting removes your profile and every stored reading. This cannot be undone.';
}
