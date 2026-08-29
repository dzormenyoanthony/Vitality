import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// The application name, shown as the task/window title.
  ///
  /// In en, this message translates to:
  /// **'Vitaly'**
  String get appTitle;

  /// Generic confirm label for a form or dialog that persists changes.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// Generic dismiss label for a dialog or flow.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Generic destructive-confirm label.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// Generic label for re-attempting a failed operation.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// Generic label for closing a sheet, dialog, or full-screen view.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// Retry button on the shared error view.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonTryAgain;

  /// Generic label for proceeding past a confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// Generic label/tooltip for a back navigation control.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// Generic dismiss label for an optional prompt the user can defer.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get commonNotNow;

  /// Placeholder shown where a value would go but none is available yet.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get commonNoData;

  /// Relative day label for the current date.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get commonToday;

  /// Relative day label for the day after the current date.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get commonTomorrow;

  /// Blood-pressure unit. Held constant across locales per PROJECT_SPEC.md §36; keyed only so it is not a bare literal in the widget tree.
  ///
  /// In en, this message translates to:
  /// **'mmHg'**
  String get unitMmhg;

  /// Pulse unit. Held constant across locales per PROJECT_SPEC.md §36; keyed only so it is not a bare literal in the widget tree.
  ///
  /// In en, this message translates to:
  /// **'bpm'**
  String get unitBpm;

  /// Bottom navigation label for the Dashboard tab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom navigation label for the blood-pressure history tab.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// Bottom navigation label for the trends tab.
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get navTrends;

  /// Bottom navigation label for the educational content tab.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get navLearn;

  /// Label on the Google sign-in button, shared by Sign In and Create Account.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueWithGoogle;

  /// Divider between Google sign-in and the email form on Sign In.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get authDividerOr;

  /// Divider between Google sign-in and the email form on Create Account.
  ///
  /// In en, this message translates to:
  /// **'OR USE EMAIL'**
  String get authDividerOrUseEmail;

  /// Uppercase floating label on the email input in the auth forms.
  ///
  /// In en, this message translates to:
  /// **'EMAIL'**
  String get authEmailFieldLabel;

  /// Uppercase floating label on the password input in the auth forms.
  ///
  /// In en, this message translates to:
  /// **'PASSWORD'**
  String get authPasswordFieldLabel;

  /// Uppercase floating label on the confirm-password input on Create Account.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM PASSWORD'**
  String get authConfirmPasswordFieldLabel;

  /// Tooltip on the reveal-password toggle when the password is hidden.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// Tooltip on the reveal-password toggle when the password is visible.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePassword;

  /// Heading on the Sign In screen.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get signInTitle;

  /// Supporting line under the Sign In heading.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue tracking your blood pressure.'**
  String get signInSubtitle;

  /// Checkbox label for persisting the session across app restarts.
  ///
  /// In en, this message translates to:
  /// **'Keep me signed in'**
  String get signInKeepSignedIn;

  /// Short link to the password-reset flow.
  ///
  /// In en, this message translates to:
  /// **'Forgot?'**
  String get signInForgot;

  /// Primary button that submits the sign-in form.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInSubmit;

  /// Leading text before the create-account link at the bottom of Sign In.
  ///
  /// In en, this message translates to:
  /// **'New here? '**
  String get signInNoAccountPrompt;

  /// Link from Sign In to the Create Account screen.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get signInCreateAccountAction;

  /// Label on the illustrative sample summary card in the Sign In hero.
  ///
  /// In en, this message translates to:
  /// **'7-DAY AVERAGE'**
  String get signInMockSevenDayAverage;

  /// Illustrative log count on the sample summary card in the Sign In hero.
  ///
  /// In en, this message translates to:
  /// **'42 logs'**
  String get signInMockLogCount;

  /// Initial shown on the illustrative avatar in the Sign In hero.
  ///
  /// In en, this message translates to:
  /// **'A'**
  String get signInMockAvatarInitial;

  /// Illustrative join-month caption under the sample avatar in the Sign In hero.
  ///
  /// In en, this message translates to:
  /// **'SINCE MAR'**
  String get signInMockSince;

  /// Snackbar shown when Create Account is submitted without ticking the terms box.
  ///
  /// In en, this message translates to:
  /// **'Please agree to the Terms and Privacy Policy first.'**
  String get signUpAgreeToTermsError;

  /// Headline in the Create Account hero header.
  ///
  /// In en, this message translates to:
  /// **'Start your blood pressure story'**
  String get signUpHeroTitle;

  /// Supporting line in the Create Account hero header.
  ///
  /// In en, this message translates to:
  /// **'Log a reading in nine seconds. Bring a real chart to your next appointment.'**
  String get signUpHeroSubtitle;

  /// Text before the Terms link in the Create Account agreement line.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get signUpAgreePrefix;

  /// The 'Terms' span in the Create Account agreement line (not yet linked).
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get signUpTermsLink;

  /// Text between the Terms and Privacy Policy spans in the agreement line.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get signUpAgreeConjunction;

  /// The 'Privacy Policy' span in the Create Account agreement line (not yet linked).
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get signUpPrivacyLink;

  /// Text after the Privacy Policy link in the Create Account agreement line.
  ///
  /// In en, this message translates to:
  /// **'. Vitaly is not a medical device.'**
  String get signUpAgreeSuffix;

  /// Primary button that submits the Create Account form.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUpSubmit;

  /// Leading text before the sign-in link at the bottom of Create Account.
  ///
  /// In en, this message translates to:
  /// **'Already with us? '**
  String get signUpHasAccountPrompt;

  /// Link from Create Account back to the Sign In screen.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signUpSignInAction;

  /// Illustrative timestamp on the floating example reading chip on Create Account.
  ///
  /// In en, this message translates to:
  /// **'TODAY 7:34'**
  String get signUpExampleReadingTime;

  /// App bar title of the password-reset screen.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get forgotPasswordAppBarTitle;

  /// Heading on the password-reset form.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get forgotPasswordTitle;

  /// Supporting line under the password-reset heading.
  ///
  /// In en, this message translates to:
  /// **'Enter your account\'s email and we\'ll send you a reset link.'**
  String get forgotPasswordSubtitle;

  /// Label on the email input in the password-reset form.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get forgotPasswordEmailLabel;

  /// Button that requests the password-reset email.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get forgotPasswordSubmit;

  /// Confirmation shown after a password-reset email has been requested.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for that email, a reset link is on its way. Check your inbox.'**
  String get forgotPasswordSentBody;

  /// Skips the rest of the onboarding carousel.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// Advances to the next onboarding carousel step.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// Finishes the onboarding carousel from its last step.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// Eyebrow badge on onboarding step 1 (recording a reading).
  ///
  /// In en, this message translates to:
  /// **'LOG'**
  String get onboardingWelcomeBadge;

  /// Headline on onboarding step 1.
  ///
  /// In en, this message translates to:
  /// **'Two numbers, five seconds.'**
  String get onboardingWelcomeTitle;

  /// Body copy on onboarding step 1.
  ///
  /// In en, this message translates to:
  /// **'Systolic and diastolic are all Vitaly needs. Pulse, posture and notes are there when you want them.'**
  String get onboardingWelcomeBody;

  /// Label on the illustrative mock reading card in onboarding step 1.
  ///
  /// In en, this message translates to:
  /// **'NEW READING'**
  String get onboardingWelcomeMockLabel;

  /// Button caption on the illustrative mock reading card in onboarding step 1.
  ///
  /// In en, this message translates to:
  /// **'Save reading'**
  String get onboardingWelcomeMockButton;

  /// Eyebrow badge on onboarding step 2 (trends).
  ///
  /// In en, this message translates to:
  /// **'TRENDS'**
  String get onboardingTrendsBadge;

  /// Headline on onboarding step 2.
  ///
  /// In en, this message translates to:
  /// **'Watch the line, not the number.'**
  String get onboardingTrendsTitle;

  /// Body copy on onboarding step 2.
  ///
  /// In en, this message translates to:
  /// **'Charts and averages show how your readings move across weeks — no labels, no verdicts.'**
  String get onboardingTrendsBody;

  /// Illustrative badge on the mock chart in onboarding step 2.
  ///
  /// In en, this message translates to:
  /// **'19 of 30 days logged'**
  String get onboardingTrendsMockDaysLogged;

  /// Range label on the illustrative mock chart in onboarding step 2.
  ///
  /// In en, this message translates to:
  /// **'30 DAYS'**
  String get onboardingTrendsMockRange;

  /// Legend label on the illustrative mock chart in onboarding step 2.
  ///
  /// In en, this message translates to:
  /// **'systolic'**
  String get onboardingTrendsMockSystolic;

  /// Legend label on the illustrative mock chart in onboarding step 2.
  ///
  /// In en, this message translates to:
  /// **'diastolic'**
  String get onboardingTrendsMockDiastolic;

  /// Eyebrow badge on onboarding step 3 (reminders).
  ///
  /// In en, this message translates to:
  /// **'ROUTINE'**
  String get onboardingRemindersBadge;

  /// Headline on onboarding step 3.
  ///
  /// In en, this message translates to:
  /// **'Reminders that fit your day.'**
  String get onboardingRemindersTitle;

  /// Body copy on onboarding step 3.
  ///
  /// In en, this message translates to:
  /// **'Set the times you measure. Vitaly nudges you, then gets out of the way.'**
  String get onboardingRemindersBody;

  /// Heading on the illustrative mock reminders card in onboarding step 3.
  ///
  /// In en, this message translates to:
  /// **'Two reminders a day'**
  String get onboardingRemindersMockTitle;

  /// First plain span of the multi-color headline on the preferred-name screen.
  ///
  /// In en, this message translates to:
  /// **'A record of your '**
  String get onboardingNameTitlePart1;

  /// Accent-colored span of the multi-color headline on the preferred-name screen.
  ///
  /// In en, this message translates to:
  /// **'blood pressure '**
  String get onboardingNameTitleEmphasis;

  /// Closing plain span of the multi-color headline on the preferred-name screen.
  ///
  /// In en, this message translates to:
  /// **'over time.'**
  String get onboardingNameTitlePart2;

  /// Non-diagnostic explanation shown on the preferred-name screen (PROJECT_SPEC.md §19).
  ///
  /// In en, this message translates to:
  /// **'Vitaly stores the readings you enter and shows how they change. It does not interpret them or give medical advice.'**
  String get onboardingNameBody;

  /// Eyebrow label above the preferred-name input.
  ///
  /// In en, this message translates to:
  /// **'WHAT SHOULD WE CALL YOU?'**
  String get onboardingNameFieldLabel;

  /// Privacy caption under the preferred-name input.
  ///
  /// In en, this message translates to:
  /// **'Used only on this device. Nothing is uploaded.'**
  String get onboardingNamePrivacyCaption;

  /// Progress footer on the preferred-name screen.
  ///
  /// In en, this message translates to:
  /// **'Step 1 of 1'**
  String get onboardingNameStepFooter;

  /// Default label for a reminder created for a morning time.
  ///
  /// In en, this message translates to:
  /// **'Morning reading'**
  String get reminderDefaultLabelMorning;

  /// Default label for a reminder created for an evening time.
  ///
  /// In en, this message translates to:
  /// **'Evening reading'**
  String get reminderDefaultLabelEvening;

  /// Confirmation snackbar shown after a reminder is created.
  ///
  /// In en, this message translates to:
  /// **'Reminder created.'**
  String get reminderCreatedSnackbar;

  /// Tooltip on the dashboard's document-scanner FAB.
  ///
  /// In en, this message translates to:
  /// **'Scan BP report'**
  String get dashboardScanFabTooltip;

  /// Label on the dashboard's primary 'record a reading' FAB.
  ///
  /// In en, this message translates to:
  /// **'Add reading'**
  String get dashboardAddReading;

  /// Shown on the dashboard before the user has any readings.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t recorded a blood pressure reading yet. Tap \"Add reading\" to add your first one.'**
  String get dashboardEmptyBody;

  /// Dashboard greeting when no preferred name is known.
  ///
  /// In en, this message translates to:
  /// **'Good {timeOfDay}'**
  String dashboardGreeting(String timeOfDay);

  /// Dashboard greeting including the user's preferred name.
  ///
  /// In en, this message translates to:
  /// **'Good {timeOfDay}, {name}'**
  String dashboardGreetingWithName(String timeOfDay, String name);

  /// Time-of-day word interpolated into the dashboard greeting (before noon).
  ///
  /// In en, this message translates to:
  /// **'morning'**
  String get dashboardTimeOfDayMorning;

  /// Time-of-day word interpolated into the dashboard greeting (noon to 18:00).
  ///
  /// In en, this message translates to:
  /// **'afternoon'**
  String get dashboardTimeOfDayAfternoon;

  /// Time-of-day word interpolated into the dashboard greeting (after 18:00).
  ///
  /// In en, this message translates to:
  /// **'evening'**
  String get dashboardTimeOfDayEvening;

  /// Date plus count-of-readings-this-week line under the dashboard greeting.
  ///
  /// In en, this message translates to:
  /// **'{dateLabel} · {count, plural, =1{1 reading} other{{count} readings}} this week'**
  String dashboardHeaderSubtitle(String dateLabel, int count);

  /// Eyebrow label on the dashboard logging-streak tile.
  ///
  /// In en, this message translates to:
  /// **'LOGGING STREAK'**
  String get dashboardStreakLabel;

  /// Streak length shown on the dashboard streak tile.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String dashboardStreakDays(int count);

  /// Button on the dashboard nudge card that creates a reminder at the suggested time.
  ///
  /// In en, this message translates to:
  /// **'Set {time} reminder'**
  String dashboardSetReminderButton(String time);

  /// Eyebrow label on the dashboard next-reminder tile.
  ///
  /// In en, this message translates to:
  /// **'NEXT REMINDER'**
  String get dashboardNextReminderLabel;

  /// Shown on the next-reminder tile when the user has no reminders.
  ///
  /// In en, this message translates to:
  /// **'No reminders set. Tap to add one.'**
  String get dashboardNoReminders;

  /// Relative day plus time for the next scheduled reminder.
  ///
  /// In en, this message translates to:
  /// **'{dayLabel} {time}'**
  String dashboardNextReminderWhen(String dayLabel, String time);

  /// Eyebrow label on the dashboard latest-reading hero card.
  ///
  /// In en, this message translates to:
  /// **'LATEST READING'**
  String get dashboardLatestReadingLabel;

  /// Pulse portion of the latest-reading subtitle.
  ///
  /// In en, this message translates to:
  /// **'Pulse {pulse} bpm'**
  String dashboardPulseSummary(int pulse);

  /// Label above the 7-day average on the latest-reading card.
  ///
  /// In en, this message translates to:
  /// **'7-DAY AVERAGE'**
  String get dashboardSevenDayAverage;

  /// Label above the 30-day average on the latest-reading card.
  ///
  /// In en, this message translates to:
  /// **'30-DAY AVERAGE'**
  String get dashboardThirtyDayAverage;

  /// Leading text of the dashboard weekly-chart legend.
  ///
  /// In en, this message translates to:
  /// **'LAST 7 DAYS · '**
  String get dashboardChartLegendPrefix;

  /// Shown in the dashboard weekly-chart card when there are no recent readings.
  ///
  /// In en, this message translates to:
  /// **'No readings recorded in the last 7 days.'**
  String get dashboardChartEmpty;

  /// Screen-reader description of the dashboard weekly trend chart.
  ///
  /// In en, this message translates to:
  /// **'Blood pressure trend for the last 7 days. See the latest reading card for the averages.'**
  String get dashboardChartSemantics;

  /// Lowercase name of the systolic data series, used in chart legends.
  ///
  /// In en, this message translates to:
  /// **'systolic'**
  String get bpSeriesSystolic;

  /// Lowercase name of the diastolic data series, used in chart legends.
  ///
  /// In en, this message translates to:
  /// **'diastolic'**
  String get bpSeriesDiastolic;

  /// Shown full-screen when Firebase or another core service fails to initialize at launch.
  ///
  /// In en, this message translates to:
  /// **'Vitaly couldn\'t start. Please try again shortly.'**
  String get startupFailureMessage;

  /// The letter-spaced brand wordmark on the splash screen.
  ///
  /// In en, this message translates to:
  /// **'VITALY'**
  String get splashWordmark;

  /// Short tagline under the wordmark on the splash screen.
  ///
  /// In en, this message translates to:
  /// **'Blood pressure, recorded'**
  String get splashTagline;

  /// Regulatory caption pinned to the bottom of the splash screen.
  ///
  /// In en, this message translates to:
  /// **'NOT A MEDICAL DEVICE'**
  String get splashNotAMedicalDevice;

  /// Header of the Settings screen.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Section label above the profile card in Settings.
  ///
  /// In en, this message translates to:
  /// **'PROFILE'**
  String get settingsSectionProfile;

  /// Section label above the appearance/theme card in Settings.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get settingsSectionAppearance;

  /// Section label above the saved-reports/export card in Settings.
  ///
  /// In en, this message translates to:
  /// **'DATA'**
  String get settingsSectionData;

  /// Section label above sign-out / delete-account in Settings.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get settingsSectionAccount;

  /// Link from Settings into the reminders screen.
  ///
  /// In en, this message translates to:
  /// **'Manage reminders'**
  String get settingsManageReminders;

  /// Field label above the editable preferred-name input in Settings.
  ///
  /// In en, this message translates to:
  /// **'Preferred name'**
  String get settingsPreferredNameLabel;

  /// Tooltip on the save button next to the preferred-name field.
  ///
  /// In en, this message translates to:
  /// **'Save name'**
  String get settingsSaveNameTooltip;

  /// Field label above the read-only account email in Settings.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get settingsEmailLabel;

  /// Caption under the account email explaining how it is used.
  ///
  /// In en, this message translates to:
  /// **'Used for sign-in and export receipts only. Readings stay on this device.'**
  String get settingsEmailCaption;

  /// Theme selector option that follows the OS setting.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeOptionSystem;

  /// Theme selector option forcing the light theme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeOptionLight;

  /// Theme selector option forcing the dark theme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeOptionDark;

  /// Helper line shown when the theme is set to System.
  ///
  /// In en, this message translates to:
  /// **'System follows your Android theme, currently {brightness}.'**
  String settingsThemeHelperSystem(String brightness);

  /// Helper line shown when the light theme is forced.
  ///
  /// In en, this message translates to:
  /// **'Using light theme.'**
  String get settingsThemeHelperLight;

  /// Helper line shown when the dark theme is forced.
  ///
  /// In en, this message translates to:
  /// **'Using dark theme.'**
  String get settingsThemeHelperDark;

  /// Lowercase word for a dark system appearance, interpolated into settingsThemeHelperSystem.
  ///
  /// In en, this message translates to:
  /// **'dark'**
  String get settingsBrightnessDark;

  /// Lowercase word for a light system appearance, interpolated into settingsThemeHelperSystem.
  ///
  /// In en, this message translates to:
  /// **'light'**
  String get settingsBrightnessLight;

  /// Toggle title for enlarging reading values app-wide.
  ///
  /// In en, this message translates to:
  /// **'Larger numbers'**
  String get settingsLargerNumbersTitle;

  /// Subtitle under the Larger numbers toggle.
  ///
  /// In en, this message translates to:
  /// **'Increase the size of reading values'**
  String get settingsLargerNumbersSubtitle;

  /// Data-section row opening the saved reports locker.
  ///
  /// In en, this message translates to:
  /// **'Saved reports'**
  String get settingsSavedReportsTitle;

  /// Subtitle for the Saved reports row.
  ///
  /// In en, this message translates to:
  /// **'Scanned or imported BP reports'**
  String get settingsSavedReportsSubtitle;

  /// Data-section row that builds and shares the full data export.
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get settingsExportDataTitle;

  /// Subtitle for the Export data row.
  ///
  /// In en, this message translates to:
  /// **'BP readings (CSV) and saved report files, as a ZIP'**
  String get settingsExportDataSubtitle;

  /// Dialog title when some report files can't be found for the export.
  ///
  /// In en, this message translates to:
  /// **'Some report files are unavailable'**
  String get settingsExportMissingTitle;

  /// Dialog body listing report files that will be omitted from the export.
  ///
  /// In en, this message translates to:
  /// **'These report files couldn\'t be found on this device and will be left out of the export:\n\n{files}\n\nThe rest of your export will still be included. Continue?'**
  String settingsExportMissingBody(String files);

  /// Snackbar shown when building the data export fails.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t prepare your export. Please try again.'**
  String get settingsExportFailed;

  /// Confirmation dialog title for account deletion.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get settingsDeleteAccountTitle;

  /// Confirmation dialog body for account deletion.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your account and all locally stored blood pressure data and reminders. This cannot be undone.'**
  String get settingsDeleteAccountBody;

  /// Button that signs the user out.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsSignOut;

  /// Button that starts the account-deletion confirmation.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settingsDeleteAccount;

  /// Caption under the delete-account button.
  ///
  /// In en, this message translates to:
  /// **'Deleting removes your profile and every stored reading. This cannot be undone.'**
  String get settingsDeleteAccountCaption;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
