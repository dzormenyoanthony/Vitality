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
  String get commonNotNow => 'Not now';

  @override
  String get commonNoData => 'No data';

  @override
  String get commonToday => 'Today';

  @override
  String get commonTomorrow => 'Tomorrow';

  @override
  String get unitMmhg => 'mmHg';

  @override
  String get unitBpm => 'bpm';

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
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get onboardingWelcomeBadge => 'LOG';

  @override
  String get onboardingWelcomeTitle => 'Two numbers, five seconds.';

  @override
  String get onboardingWelcomeBody =>
      'Systolic and diastolic are all Vitaly needs. Pulse, posture and notes are there when you want them.';

  @override
  String get onboardingWelcomeMockLabel => 'NEW READING';

  @override
  String get onboardingWelcomeMockButton => 'Save reading';

  @override
  String get onboardingTrendsBadge => 'TRENDS';

  @override
  String get onboardingTrendsTitle => 'Watch the line, not the number.';

  @override
  String get onboardingTrendsBody =>
      'Charts and averages show how your readings move across weeks — no labels, no verdicts.';

  @override
  String get onboardingTrendsMockDaysLogged => '19 of 30 days logged';

  @override
  String get onboardingTrendsMockRange => '30 DAYS';

  @override
  String get onboardingTrendsMockSystolic => 'systolic';

  @override
  String get onboardingTrendsMockDiastolic => 'diastolic';

  @override
  String get onboardingRemindersBadge => 'ROUTINE';

  @override
  String get onboardingRemindersTitle => 'Reminders that fit your day.';

  @override
  String get onboardingRemindersBody =>
      'Set the times you measure. Vitaly nudges you, then gets out of the way.';

  @override
  String get onboardingRemindersMockTitle => 'Two reminders a day';

  @override
  String get onboardingNameTitlePart1 => 'A record of your ';

  @override
  String get onboardingNameTitleEmphasis => 'blood pressure ';

  @override
  String get onboardingNameTitlePart2 => 'over time.';

  @override
  String get onboardingNameBody =>
      'Vitaly stores the readings you enter and shows how they change. It does not interpret them or give medical advice.';

  @override
  String get onboardingNameFieldLabel => 'WHAT SHOULD WE CALL YOU?';

  @override
  String get onboardingNamePrivacyCaption =>
      'Used only on this device. Nothing is uploaded.';

  @override
  String get onboardingNameStepFooter => 'Step 1 of 1';

  @override
  String get reminderDefaultLabelMorning => 'Morning reading';

  @override
  String get reminderDefaultLabelEvening => 'Evening reading';

  @override
  String get reminderCreatedSnackbar => 'Reminder created.';

  @override
  String get dashboardScanFabTooltip => 'Scan BP report';

  @override
  String get dashboardAddReading => 'Add reading';

  @override
  String get dashboardEmptyBody =>
      'You haven\'t recorded a blood pressure reading yet. Tap \"Add reading\" to add your first one.';

  @override
  String dashboardGreeting(String timeOfDay) {
    return 'Good $timeOfDay';
  }

  @override
  String dashboardGreetingWithName(String timeOfDay, String name) {
    return 'Good $timeOfDay, $name';
  }

  @override
  String get dashboardTimeOfDayMorning => 'morning';

  @override
  String get dashboardTimeOfDayAfternoon => 'afternoon';

  @override
  String get dashboardTimeOfDayEvening => 'evening';

  @override
  String dashboardHeaderSubtitle(String dateLabel, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count readings',
      one: '1 reading',
    );
    return '$dateLabel · $_temp0 this week';
  }

  @override
  String get dashboardStreakLabel => 'LOGGING STREAK';

  @override
  String dashboardStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String dashboardSetReminderButton(String time) {
    return 'Set $time reminder';
  }

  @override
  String get dashboardNextReminderLabel => 'NEXT REMINDER';

  @override
  String get dashboardNoReminders => 'No reminders set. Tap to add one.';

  @override
  String dashboardNextReminderWhen(String dayLabel, String time) {
    return '$dayLabel $time';
  }

  @override
  String get dashboardLatestReadingLabel => 'LATEST READING';

  @override
  String dashboardPulseSummary(int pulse) {
    return 'Pulse $pulse bpm';
  }

  @override
  String get dashboardSevenDayAverage => '7-DAY AVERAGE';

  @override
  String get dashboardThirtyDayAverage => '30-DAY AVERAGE';

  @override
  String get dashboardChartLegendPrefix => 'LAST 7 DAYS · ';

  @override
  String get dashboardChartEmpty => 'No readings recorded in the last 7 days.';

  @override
  String get dashboardChartSemantics =>
      'Blood pressure trend for the last 7 days. See the latest reading card for the averages.';

  @override
  String get bpSeriesSystolic => 'systolic';

  @override
  String get bpSeriesDiastolic => 'diastolic';

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
