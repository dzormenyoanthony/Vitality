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
