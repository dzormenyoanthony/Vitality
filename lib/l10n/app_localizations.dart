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

  /// Dropdown option representing no selection.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get commonNone;

  /// Generic label for a control that opens an editor for an adjacent value.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get commonChange;

  /// Placeholder shown where an optional value has not been chosen.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get commonNotSet;

  /// Accessibility label for an in-progress save spinner.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get commonSaving;

  /// Generic label for an export action.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get commonExport;

  /// Generic label/tooltip for an edit action.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// Generic warning line in a destructive-confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get commonCannotBeUndone;

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

  /// Header of the Reminders screen.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersTitle;

  /// Days-summary text / preset button meaning all seven days.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get remindersEveryDay;

  /// Intro line on the Reminders screen (PROJECT_SPEC.md §13, §17). Approved wording; any change needs the §37 review.
  ///
  /// In en, this message translates to:
  /// **'Reminders prompt you to measure. Vitaly never asks you to change medication or treatment.'**
  String get remindersIntro;

  /// Shown on the Reminders screen when the user has no reminders.
  ///
  /// In en, this message translates to:
  /// **'No reminders yet.'**
  String get remindersEmpty;

  /// Button that opens the inline new-reminder card / the reminder form.
  ///
  /// In en, this message translates to:
  /// **'Add reminder'**
  String get remindersAddButton;

  /// Footer note on the Reminders screen (PROJECT_SPEC.md §23). Approved wording; any change needs the §37 review.
  ///
  /// In en, this message translates to:
  /// **'Notifications are delivered by Android. Silent hours are respected. Status colours describe delivery only, never your readings.'**
  String get remindersFooter;

  /// Leading text of the notifications-disabled banner; followed by the settings link.
  ///
  /// In en, this message translates to:
  /// **'System notifications for Vitaly are switched off. '**
  String get remindersNotificationsOffPrefix;

  /// Link in the notifications-disabled banner that opens the OS notification settings.
  ///
  /// In en, this message translates to:
  /// **'Open Android settings'**
  String get remindersOpenAndroidSettings;

  /// Confirmation dialog title for deleting a reminder.
  ///
  /// In en, this message translates to:
  /// **'Delete this reminder?'**
  String get remindersDeleteTitle;

  /// Confirmation dialog body for deleting a reminder.
  ///
  /// In en, this message translates to:
  /// **'\"{label}\" will no longer remind you.'**
  String remindersDeleteBody(String label);

  /// Status word for a disabled reminder, shown after the days summary.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get remindersStatusOff;

  /// Status word for an active reminder with no quiet hours.
  ///
  /// In en, this message translates to:
  /// **'delivering'**
  String get remindersStatusDelivering;

  /// Status fragment for an active reminder whose time falls in its quiet-hours window.
  ///
  /// In en, this message translates to:
  /// **'silenced {range}'**
  String remindersStatusSilenced(String range);

  /// Eyebrow label on the inline quick-add reminder card.
  ///
  /// In en, this message translates to:
  /// **'NEW REMINDER'**
  String get remindersNewReminderLabel;

  /// Eyebrow label above the repeat-day selector in the quick-add card.
  ///
  /// In en, this message translates to:
  /// **'REPEAT'**
  String get remindersRepeatLabel;

  /// App bar title of the reminder form when creating.
  ///
  /// In en, this message translates to:
  /// **'Add reminder'**
  String get reminderFormTitleAdd;

  /// App bar title of the reminder form when editing.
  ///
  /// In en, this message translates to:
  /// **'Edit reminder'**
  String get reminderFormTitleEdit;

  /// Field label for the reminder's name.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get reminderFormLabelField;

  /// Validation message when the reminder label is empty.
  ///
  /// In en, this message translates to:
  /// **'Enter a label.'**
  String get reminderFormLabelRequired;

  /// Row label for the reminder's time-of-day.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get reminderFormTimeLabel;

  /// Heading above the weekday selector on the reminder form.
  ///
  /// In en, this message translates to:
  /// **'Repeat on'**
  String get reminderFormRepeatOn;

  /// Heading above the optional quiet-hours fields.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours (optional)'**
  String get reminderFormQuietHours;

  /// Explains what quiet hours do on the reminder form.
  ///
  /// In en, this message translates to:
  /// **'If this reminder\'s time falls in this window, it\'s delivered silently instead of not at all.'**
  String get reminderFormQuietHoursHelp;

  /// Label for the quiet-hours start time.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get reminderFormQuietFrom;

  /// Label for the quiet-hours end time.
  ///
  /// In en, this message translates to:
  /// **'Until'**
  String get reminderFormQuietUntil;

  /// Button that removes the quiet-hours window.
  ///
  /// In en, this message translates to:
  /// **'Clear quiet hours'**
  String get reminderFormClearQuietHours;

  /// Validation message when no repeat day is selected.
  ///
  /// In en, this message translates to:
  /// **'Select at least one day.'**
  String get reminderFormSelectDay;

  /// Saved-report category tag.
  ///
  /// In en, this message translates to:
  /// **'BP report'**
  String get reportCategoryBpReport;

  /// Saved-report category tag.
  ///
  /// In en, this message translates to:
  /// **'Lab results'**
  String get reportCategoryLabResults;

  /// Saved-report category tag.
  ///
  /// In en, this message translates to:
  /// **'Prescriptions'**
  String get reportCategoryPrescriptions;

  /// Saved-report category tag.
  ///
  /// In en, this message translates to:
  /// **'ECG'**
  String get reportCategoryEcg;

  /// Saved-report category tag (unspecified).
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reportCategoryOther;

  /// Explains the scan flow on the entry sheet (PROJECT_SPEC.md §6). Approved wording; any change needs the §37 review.
  ///
  /// In en, this message translates to:
  /// **'Vitaly will look for blood pressure values, but you always review and confirm them before anything is saved.'**
  String get scanSheetBody;

  /// Entry-sheet option to open the document scanner.
  ///
  /// In en, this message translates to:
  /// **'Scan with camera'**
  String get scanSheetCamera;

  /// Entry-sheet option to pick an existing file.
  ///
  /// In en, this message translates to:
  /// **'Import from device'**
  String get scanSheetImport;

  /// Subtitle under the import option, listing accepted file types.
  ///
  /// In en, this message translates to:
  /// **'Image or PDF'**
  String get scanSheetImportSubtitle;

  /// Snackbar when the camera scanner fails to open.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the scanner. Please try again.'**
  String get scanScannerError;

  /// Snackbar when importing a picked file fails.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t import that file. Please try again.'**
  String get scanImportError;

  /// App bar title shown while a saved report's own title is still loading.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportViewerFallbackTitle;

  /// Shown when a report viewer is opened for a deleted report.
  ///
  /// In en, this message translates to:
  /// **'This report is no longer available.'**
  String get reportViewerNotFound;

  /// Shown when a saved report has no local page files.
  ///
  /// In en, this message translates to:
  /// **'This report\'s original document isn\'t available on this device.'**
  String get reportViewerNoDocument;

  /// Shown for a single report page whose file is missing locally.
  ///
  /// In en, this message translates to:
  /// **'This page isn\'t available offline.'**
  String get reportViewerPageOffline;

  /// Page position indicator under a multi-page report.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {total}'**
  String reportViewerPageIndicator(int page, int total);

  /// Header of the Saved Reports 'document locker' screen.
  ///
  /// In en, this message translates to:
  /// **'My saved reports'**
  String get savedReportsTitle;

  /// Empty state on the Saved Reports screen.
  ///
  /// In en, this message translates to:
  /// **'No saved reports yet. Scan or import a report to get started.'**
  String get savedReportsEmpty;

  /// Shown when a category filter matches no saved reports.
  ///
  /// In en, this message translates to:
  /// **'No reports in this category yet.'**
  String get savedReportsEmptyCategory;

  /// Section label grouping reports dated in the current month.
  ///
  /// In en, this message translates to:
  /// **'THIS MONTH'**
  String get savedReportsThisMonth;

  /// Section label grouping reports dated before the current month.
  ///
  /// In en, this message translates to:
  /// **'EARLIER'**
  String get savedReportsEarlier;

  /// Eyebrow label on the storage-usage hero card.
  ///
  /// In en, this message translates to:
  /// **'YOUR DOCUMENT LOCKER'**
  String get savedReportsLockerEyebrow;

  /// Follows the file count on the locker hero card, e.g. '3  files · 1.8 MB'.
  ///
  /// In en, this message translates to:
  /// **'files · {size}'**
  String savedReportsLockerFilesSize(String size);

  /// Locker hero button that imports a file from the device.
  ///
  /// In en, this message translates to:
  /// **'Upload report'**
  String get savedReportsUpload;

  /// Locker hero button that opens the camera scanner.
  ///
  /// In en, this message translates to:
  /// **'Scan a page'**
  String get savedReportsScanPage;

  /// The 'all categories' filter chip, with the total report count.
  ///
  /// In en, this message translates to:
  /// **'All {count}'**
  String savedReportsCategoryAll(int count);

  /// A category filter chip: the category name plus how many reports it holds.
  ///
  /// In en, this message translates to:
  /// **'{label} {count}'**
  String savedReportsCategoryChip(String label, int count);

  /// Badge on a report card whose document is a PDF.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get savedReportsTypePdf;

  /// Badge on a report card whose document is an image.
  ///
  /// In en, this message translates to:
  /// **'IMG'**
  String get savedReportsTypeImage;

  /// Menu item / dialog title for editing a report's title, category, and source.
  ///
  /// In en, this message translates to:
  /// **'Edit details'**
  String get savedReportsEditDetails;

  /// Field label for a report's title in the edit-details dialog.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get savedReportsFieldTitle;

  /// Field label for a report's category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get savedReportsFieldCategory;

  /// Field label for a report's optional provider/source note.
  ///
  /// In en, this message translates to:
  /// **'Source (optional)'**
  String get savedReportsFieldSource;

  /// Confirmation dialog title for deleting a saved report.
  ///
  /// In en, this message translates to:
  /// **'Delete this report?'**
  String get savedReportsDeleteTitle;

  /// Confirmation dialog body for deleting a saved report.
  ///
  /// In en, this message translates to:
  /// **'The saved document and its extracted information will be removed. This cannot be undone.'**
  String get savedReportsDeleteBody;

  /// Dashed-border footer note on the Saved Reports screen. Kept verbatim per pixel-fidelity direction.
  ///
  /// In en, this message translates to:
  /// **'Files stay on this device unless you share them. Attach any report to a reading from its detail view.'**
  String get savedReportsFooter;

  /// App bar title of the OCR review screen (PROJECT_SPEC.md §5).
  ///
  /// In en, this message translates to:
  /// **'Review extracted information'**
  String get reviewTitle;

  /// Default title given to a newly saved scanned report.
  ///
  /// In en, this message translates to:
  /// **'Scanned report – {date}'**
  String reviewScannedReportTitle(String date);

  /// Snackbar after saving a report with no readings added to history.
  ///
  /// In en, this message translates to:
  /// **'Report saved.'**
  String get reviewReportSaved;

  /// Snackbar after saving a report and adding confirmed readings to BP History.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Report saved and 1 reading added to BP History.} other{Report saved and {count} readings added to BP History.}}'**
  String reviewReportSavedWithReadings(int count);

  /// Confirm button when OCR failed — saves the original document only.
  ///
  /// In en, this message translates to:
  /// **'Save report without extracted info'**
  String get reviewSaveWithoutInfo;

  /// Confirm button that saves the report and any confirmed readings.
  ///
  /// In en, this message translates to:
  /// **'Confirm and save'**
  String get reviewConfirmAndSave;

  /// Card heading for the category/source fields on the review screen.
  ///
  /// In en, this message translates to:
  /// **'Document details'**
  String get reviewDocumentDetails;

  /// Hint text for the optional source field.
  ///
  /// In en, this message translates to:
  /// **'e.g. Dr. Okafor, Northside Lab'**
  String get reviewSourceHint;

  /// Shown while OCR is running on the imported pages.
  ///
  /// In en, this message translates to:
  /// **'Reading your report…'**
  String get reviewProcessing;

  /// OCR-failure heading (PROJECT_SPEC.md §13, exact wording). Any change needs the §37 review.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t reliably read this report.'**
  String get reviewOcrFailedTitle;

  /// OCR-failure explanation with the available next steps.
  ///
  /// In en, this message translates to:
  /// **'You can retry, or save the original document without extracted information — you can always add readings manually afterward.'**
  String get reviewOcrFailedBody;

  /// Button that returns to the scan/import entry point after an OCR failure.
  ///
  /// In en, this message translates to:
  /// **'Scan or import again'**
  String get reviewScanAgain;

  /// Shown when OCR found no BP readings.
  ///
  /// In en, this message translates to:
  /// **'No blood pressure readings were detected. You can add one manually.'**
  String get reviewNoReadings;

  /// Instructions above the detected-readings list (PROJECT_SPEC.md §6). Approved wording; any change needs the §37 review.
  ///
  /// In en, this message translates to:
  /// **'Review each detected reading. Only what you confirm and select is added to BP History.'**
  String get reviewInstructions;

  /// Button that opens the editor to add a reading OCR missed.
  ///
  /// In en, this message translates to:
  /// **'Add a missing reading'**
  String get reviewAddMissing;

  /// The systolic/diastolic value on a detected-reading card.
  ///
  /// In en, this message translates to:
  /// **'{systolic}/{diastolic} mmHg'**
  String reviewReadingValue(int systolic, int diastolic);

  /// Low-confidence badge on a detected value (PROJECT_SPEC.md §14, exact wording).
  ///
  /// In en, this message translates to:
  /// **'Needs review'**
  String get reviewNeedsReview;

  /// Shown on a detected-reading card when OCR found no date.
  ///
  /// In en, this message translates to:
  /// **'No date detected'**
  String get reviewNoDate;

  /// Button in the reading editor that opens the date/time pickers.
  ///
  /// In en, this message translates to:
  /// **'Change date'**
  String get reviewChangeDate;

  /// Education library section name.
  ///
  /// In en, this message translates to:
  /// **'Basics'**
  String get articleCategoryBasics;

  /// Education library section name.
  ///
  /// In en, this message translates to:
  /// **'Measuring well'**
  String get articleCategoryMeasuringWell;

  /// Education library section name.
  ///
  /// In en, this message translates to:
  /// **'Working with your clinician'**
  String get articleCategoryWorkingWithClinician;

  /// Header of the education library screen.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get educationTitle;

  /// Intro line clarifying the education library is not personalized advice (PROJECT_SPEC.md §15). Approved wording; any change needs the §37 review.
  ///
  /// In en, this message translates to:
  /// **'General information about blood pressure and measurement. Not advice about your own readings.'**
  String get educationIntro;

  /// Footer note on the education library. Approved wording; any change needs the §37 review.
  ///
  /// In en, this message translates to:
  /// **'Sources listed on each article. If you feel unwell, contact a clinician or emergency services.'**
  String get educationFooter;

  /// Compact read-time shown on an article row.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String articleReadTimeMinutes(int minutes);

  /// Article row subtitle: one-line summary plus read time.
  ///
  /// In en, this message translates to:
  /// **'{summary} · {minutes} min'**
  String articleRowSubtitle(String summary, int minutes);

  /// Metadata line on the featured article card.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min read · Reviewed {date}'**
  String articleReviewedLine(int minutes, String date);

  /// Metadata line under an article's title on the detail screen.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min read · Reviewed {date} · General information'**
  String articleDetailMetaLine(int minutes, String date);

  /// Shown when an article detail screen is opened for a missing article.
  ///
  /// In en, this message translates to:
  /// **'This article is no longer available.'**
  String get articleNotFound;

  /// Attribution line at the foot of an article.
  ///
  /// In en, this message translates to:
  /// **'Source: {source}'**
  String articleSourceLine(String source);

  /// Closing disclaimer on every article (PROJECT_SPEC.md §15). Approved wording; any change needs the §37 review.
  ///
  /// In en, this message translates to:
  /// **'This is general information, not personalized medical advice. If you feel unwell, contact a clinician or emergency services.'**
  String get articleDisclaimer;

  /// Section label in the 'how to measure at home' article.
  ///
  /// In en, this message translates to:
  /// **'BEFORE YOU MEASURE'**
  String get measureWellBeforeYouMeasure;

  /// Measurement-technique step (PROJECT_SPEC.md §16). Approved content; any change needs the §37 review.
  ///
  /// In en, this message translates to:
  /// **'Avoid caffeine, smoking and exercise for 30 minutes.'**
  String get measureWellStep1;

  /// Measurement-technique step (PROJECT_SPEC.md §16). Approved content; any change needs the §37 review.
  ///
  /// In en, this message translates to:
  /// **'Empty your bladder, then sit quietly for five minutes.'**
  String get measureWellStep2;

  /// Measurement-technique step (PROJECT_SPEC.md §16). Approved content; any change needs the §37 review.
  ///
  /// In en, this message translates to:
  /// **'Sit with your back supported and both feet flat on the floor.'**
  String get measureWellStep3;

  /// Section label in the 'how to measure at home' article.
  ///
  /// In en, this message translates to:
  /// **'CUFF PLACEMENT'**
  String get measureWellCuffPlacement;

  /// Measurement-technique guidance (PROJECT_SPEC.md §16). Approved content; any change needs the §37 review.
  ///
  /// In en, this message translates to:
  /// **'Rest your arm on a table so the cuff sits level with your heart, with the cuff\'s lower edge about 2 cm above the elbow crease, snug but not tight, directly on skin rather than over clothing.'**
  String get measureWellCuffParagraph;

  /// Callout label on the cuff-placement diagram.
  ///
  /// In en, this message translates to:
  /// **'heart level'**
  String get measureWellHeartLevel;

  /// Callout label on the cuff-placement diagram.
  ///
  /// In en, this message translates to:
  /// **'2 cm above the elbow crease'**
  String get measureWellElbowCallout;

  /// Caption under the cuff-placement diagram.
  ///
  /// In en, this message translates to:
  /// **'Cuff centred over the artery, level with the heart.'**
  String get measureWellDiagramCaption;

  /// Fixed illustrative device readout (diastolic value + unit) on the cuff-placement diagram.
  ///
  /// In en, this message translates to:
  /// **'82  mmHg'**
  String get measureWellDiagramReadingUnit;

  /// Non-diagnostic status label for the NORMAL BP category (PROJECT_SPEC.md §21, §29). Approved wording; any change needs clinical/§37 review.
  ///
  /// In en, this message translates to:
  /// **'Looks good'**
  String get bpCategoryLooksGood;

  /// Non-diagnostic status label for the ELEVATED BP category (PROJECT_SPEC.md §21, §29). Approved wording; any change needs clinical/§37 review.
  ///
  /// In en, this message translates to:
  /// **'Worth keeping an eye on'**
  String get bpCategoryWorthKeepingAnEyeOn;

  /// Non-diagnostic status label for the HIGHER BP category (PROJECT_SPEC.md §21, §29). Approved wording; any change needs clinical/§37 review.
  ///
  /// In en, this message translates to:
  /// **'Higher than the usual range'**
  String get bpCategoryHigherThanUsual;

  /// Non-diagnostic status label for the HIGH BP category (PROJECT_SPEC.md §21, §29). Approved wording; any change needs clinical/§37 review.
  ///
  /// In en, this message translates to:
  /// **'This reading is high'**
  String get bpCategoryReadingIsHigh;

  /// Lowercase category noun for the category-movement sentence.
  ///
  /// In en, this message translates to:
  /// **'normal'**
  String get bpCategoryNameNormal;

  /// Lowercase category noun for the category-movement sentence.
  ///
  /// In en, this message translates to:
  /// **'elevated'**
  String get bpCategoryNameElevated;

  /// Lowercase category noun for the category-movement sentence.
  ///
  /// In en, this message translates to:
  /// **'higher'**
  String get bpCategoryNameHigher;

  /// Lowercase category noun for the category-movement sentence.
  ///
  /// In en, this message translates to:
  /// **'high'**
  String get bpCategoryNameHigh;

  /// "Why am I seeing this?" explanation, generated from the classification data (PROJECT_SPEC.md §24). Approved wording; any change needs clinical/§37 review.
  ///
  /// In en, this message translates to:
  /// **'Your recorded blood pressure was {systolic}/{diastolic} mmHg. The systolic value falls within the {systolicRange} range and the diastolic value falls within the {diastolicRange} range. This classification describes this recorded reading. It is not a diagnosis.'**
  String bpExplanation(
    int systolic,
    int diastolic,
    String systolicRange,
    String diastolicRange,
  );

  /// Title of the classification explanation bottom sheet (PROJECT_SPEC.md §24).
  ///
  /// In en, this message translates to:
  /// **'Why am I seeing this?'**
  String get bpWhyAmISeeingThis;

  /// Screen-reader label for a non-interactive status badge.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String bpStatusSemanticsLabel(String status);

  /// Screen-reader label for a status badge that opens the explanation sheet.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}. Why am I seeing this?'**
  String bpStatusSemanticsLabelInteractive(String status);

  /// Trend summary sentence (PROJECT_SPEC.md §12). Approved non-diagnostic wording; any change needs the §37 review.
  ///
  /// In en, this message translates to:
  /// **'Your average systolic reading over the last {period} was {value} mmHg.'**
  String trendSummaryAvgSystolic(String period, int value);

  /// Trend summary sentence (PROJECT_SPEC.md §12). Approved non-diagnostic wording; any change needs the §37 review.
  ///
  /// In en, this message translates to:
  /// **'Your average diastolic reading over the last {period} was {value} mmHg.'**
  String trendSummaryAvgDiastolic(String period, int value);

  /// Trend summary sentence (PROJECT_SPEC.md §12). Approved non-diagnostic wording; any change needs the §37 review.
  ///
  /// In en, this message translates to:
  /// **'Your average pulse over the last {period} was {value} bpm.'**
  String trendSummaryAvgPulse(String period, int value);

  /// Trend summary line stating the classification of the period average (PROJECT_SPEC.md §12, §23). Approved wording; any change needs the §37 review.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Average status (1 reading): {status}.} other{Average status ({count} readings): {status}.}}'**
  String trendSummaryAverageStatus(int count, String status);

  /// Trend summary line stating how many readings were recorded (PROJECT_SPEC.md §12). Approved wording; any change needs the §37 review.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{You recorded 1 reading during this period.} other{You recorded {count} readings during this period.}}'**
  String trendSummaryReadingCount(int count);

  /// Phrase used in place of a fixed window when the trend period is 'all history' (PROJECT_SPEC.md §12).
  ///
  /// In en, this message translates to:
  /// **'available history'**
  String get trendSummaryPeriodAll;

  /// Category-movement sentence (PROJECT_SPEC.md §27) — always phrased as a category change, never a health improvement/decline. Approved wording; any change needs the §37 review.
  ///
  /// In en, this message translates to:
  /// **'Your average recorded reading moved from the {previous} category to the {current} category.'**
  String trendCategoryMovement(String previous, String current);

  /// Trend frequency comparison (PROJECT_SPEC.md §12). Approved wording; any change needs the §37 review.
  ///
  /// In en, this message translates to:
  /// **'You recorded the same number of readings as last period.'**
  String get trendFrequencySame;

  /// Trend frequency comparison (PROJECT_SPEC.md §12). Approved wording; any change needs the §37 review.
  ///
  /// In en, this message translates to:
  /// **'You recorded fewer readings this period than last.'**
  String get trendFrequencyFewer;

  /// Trend frequency comparison (PROJECT_SPEC.md §12). Approved wording; any change needs the §37 review.
  ///
  /// In en, this message translates to:
  /// **'You recorded more readings this period than last.'**
  String get trendFrequencyMore;

  /// Top-level header of the exported Trends PDF.
  ///
  /// In en, this message translates to:
  /// **'Vitaly - Trend Summary'**
  String get trendPdfTitle;

  /// Timestamp line at the top of the exported Trends PDF.
  ///
  /// In en, this message translates to:
  /// **'Generated {date}'**
  String trendPdfGenerated(String date);

  /// Section header above the reading table in the exported Trends PDF.
  ///
  /// In en, this message translates to:
  /// **'Readings in this period'**
  String get trendPdfReadingsHeader;

  /// Trends PDF reading-table column header.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get trendPdfColDate;

  /// Trends PDF reading-table column header.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get trendPdfColTime;

  /// Trends PDF reading-table column header.
  ///
  /// In en, this message translates to:
  /// **'Systolic'**
  String get trendPdfColSystolic;

  /// Trends PDF reading-table column header.
  ///
  /// In en, this message translates to:
  /// **'Diastolic'**
  String get trendPdfColDiastolic;

  /// Trends PDF reading-table column header.
  ///
  /// In en, this message translates to:
  /// **'Pulse'**
  String get trendPdfColPulse;

  /// Non-diagnostic disclaimer in the exported Trends PDF (PROJECT_SPEC.md §12, §28). Approved wording; any change needs the §37 review.
  ///
  /// In en, this message translates to:
  /// **'This is a record of self-reported home readings. It does not diagnose or interpret your blood pressure. Share it with your healthcare professional.'**
  String get trendPdfDisclaimer;

  /// Dashboard nudge shown when mornings are underrepresented, derived only from logging counts (PROJECT_SPEC.md §12-14) — never a comment on reading values.
  ///
  /// In en, this message translates to:
  /// **'You logged {morningDays} of the last 7 mornings and {eveningDays} evenings. A morning reminder would even out the record.'**
  String loggingInsightMorningGap(int morningDays, int eveningDays);

  /// Dashboard nudge shown when evenings are underrepresented, derived only from logging counts (PROJECT_SPEC.md §12-14) — never a comment on reading values.
  ///
  /// In en, this message translates to:
  /// **'You logged {eveningDays} of the last 7 evenings and {morningDays} mornings. An evening reminder would even out the record.'**
  String loggingInsightEveningGap(int eveningDays, int morningDays);

  /// Header of the Export data screen.
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get exportDataTitle;

  /// Eyebrow on the Export data hero card.
  ///
  /// In en, this message translates to:
  /// **'READY TO EXPORT'**
  String get exportReadyEyebrow;

  /// Follows the big reading count on the hero card, e.g. '42  readings · Jul 21 – Aug 21'.
  ///
  /// In en, this message translates to:
  /// **'{readingsWord} · {span}'**
  String exportReadySpan(String readingsWord, String span);

  /// The word 'reading(s)' agreeing with the export count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{reading} other{readings}}'**
  String exportReadingsWord(int count);

  /// Line on the hero card summarising attached scanned documents.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No attached documents} =1{Includes 1 attached document ({size})} other{Includes {count} attached documents ({size})}}'**
  String exportIncludesDocuments(int count, String size);

  /// Shown on the hero card when the selected date range has no readings.
  ///
  /// In en, this message translates to:
  /// **'No readings in this range yet.'**
  String get exportEmptyRange;

  /// Section label above the date-range chips.
  ///
  /// In en, this message translates to:
  /// **'DATE RANGE'**
  String get exportSectionDateRange;

  /// Date-range chip.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get exportRangeLast30Days;

  /// Date-range chip.
  ///
  /// In en, this message translates to:
  /// **'90 days'**
  String get exportRangeLast90Days;

  /// Date-range chip.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get exportRangeThisYear;

  /// Date-range chip.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get exportRangeAllTime;

  /// Section label above the format options.
  ///
  /// In en, this message translates to:
  /// **'FORMAT'**
  String get exportSectionFormat;

  /// Format option: the one-page Trends PDF.
  ///
  /// In en, this message translates to:
  /// **'PDF summary'**
  String get exportFormatPdfTitle;

  /// Subtitle for the PDF summary format option.
  ///
  /// In en, this message translates to:
  /// **'One page for your doctor — averages, chart, notes'**
  String get exportFormatPdfSubtitle;

  /// Format option: the readings CSV on its own.
  ///
  /// In en, this message translates to:
  /// **'CSV spreadsheet'**
  String get exportFormatCsvTitle;

  /// Subtitle for the CSV format option.
  ///
  /// In en, this message translates to:
  /// **'Every reading as a row, for your own analysis'**
  String get exportFormatCsvSubtitle;

  /// Format option: CSV plus scanned documents, zipped (PROJECT_SPEC.md §28).
  ///
  /// In en, this message translates to:
  /// **'Full archive'**
  String get exportFormatArchiveTitle;

  /// Subtitle for the full-archive format option.
  ///
  /// In en, this message translates to:
  /// **'Readings plus all scanned documents, zipped'**
  String get exportFormatArchiveSubtitle;

  /// File-type badge on the PDF format option.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get exportBadgePdf;

  /// File-type badge on the CSV format option.
  ///
  /// In en, this message translates to:
  /// **'CSV'**
  String get exportBadgeCsv;

  /// File-type badge on the full-archive format option.
  ///
  /// In en, this message translates to:
  /// **'ZIP'**
  String get exportBadgeZip;

  /// Toggle: keep the Notes and Measurement Context CSV columns.
  ///
  /// In en, this message translates to:
  /// **'Include notes and tags'**
  String get exportToggleNotes;

  /// Toggle: include the scanned_reports/ folder in the full archive.
  ///
  /// In en, this message translates to:
  /// **'Include attached documents'**
  String get exportToggleDocuments;

  /// Toggle: keep the Pulse column/line in the export.
  ///
  /// In en, this message translates to:
  /// **'Include pulse readings'**
  String get exportTogglePulse;

  /// Privacy caption on the Export data screen (PROJECT_SPEC.md §25, §28).
  ///
  /// In en, this message translates to:
  /// **'The file is built on this device and handed straight to the app you choose. Vitaly keeps no copy.'**
  String get exportPrivacyNote;

  /// The primary export action button, with the count of readings in the selected range.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Export} =1{Export 1 reading} other{Export {count} readings}}'**
  String exportButton(int count);

  /// Record-reading form validation.
  ///
  /// In en, this message translates to:
  /// **'Enter a systolic value.'**
  String get validationSystolicRequired;

  /// Record-reading form validation.
  ///
  /// In en, this message translates to:
  /// **'Systolic must be a whole number.'**
  String get validationSystolicWholeNumber;

  /// Record-reading form validation; the range is an input check, not a diagnostic threshold (PROJECT_SPEC.md §7).
  ///
  /// In en, this message translates to:
  /// **'Systolic must be between {min} and {max} mmHg.'**
  String validationSystolicRange(int min, int max);

  /// Record-reading form validation.
  ///
  /// In en, this message translates to:
  /// **'Enter a diastolic value.'**
  String get validationDiastolicRequired;

  /// Record-reading form validation.
  ///
  /// In en, this message translates to:
  /// **'Diastolic must be a whole number.'**
  String get validationDiastolicWholeNumber;

  /// Record-reading form validation; the range is an input check, not a diagnostic threshold (PROJECT_SPEC.md §7).
  ///
  /// In en, this message translates to:
  /// **'Diastolic must be between {min} and {max} mmHg.'**
  String validationDiastolicRange(int min, int max);

  /// Record-reading form validation.
  ///
  /// In en, this message translates to:
  /// **'Pulse must be a whole number.'**
  String get validationPulseWholeNumber;

  /// Record-reading form validation for the optional pulse field.
  ///
  /// In en, this message translates to:
  /// **'Pulse must be between {min} and {max} bpm.'**
  String validationPulseRange(int min, int max);

  /// Auth form validation.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address.'**
  String get validationEmailRequired;

  /// Auth form validation.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get validationEmailInvalid;

  /// Auth form validation.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get validationPasswordRequired;

  /// Auth form validation for the minimum password length.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least {min} characters.'**
  String validationPasswordTooShort(int min);

  /// Create-account form validation.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password.'**
  String get validationConfirmPasswordRequired;

  /// Create-account form validation.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get validationPasswordsDoNotMatch;

  /// Preferred-name form validation.
  ///
  /// In en, this message translates to:
  /// **'Enter a preferred name.'**
  String get validationPreferredNameRequired;

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

  /// Measurement-context tag.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get contextMorning;

  /// Measurement-context tag.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get contextEvening;

  /// Measurement-context tag.
  ///
  /// In en, this message translates to:
  /// **'Before medication'**
  String get contextBeforeMedication;

  /// Measurement-context tag.
  ///
  /// In en, this message translates to:
  /// **'After medication'**
  String get contextAfterMedication;

  /// Measurement-context tag.
  ///
  /// In en, this message translates to:
  /// **'After exercise'**
  String get contextAfterExercise;

  /// Measurement-context tag.
  ///
  /// In en, this message translates to:
  /// **'After meal'**
  String get contextAfterMeal;

  /// Measurement-context tag (unspecified).
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get contextOther;

  /// Body-position option when recording a reading.
  ///
  /// In en, this message translates to:
  /// **'Sitting'**
  String get bodyPositionSitting;

  /// Body-position option when recording a reading.
  ///
  /// In en, this message translates to:
  /// **'Standing'**
  String get bodyPositionStanding;

  /// Body-position option when recording a reading.
  ///
  /// In en, this message translates to:
  /// **'Lying down'**
  String get bodyPositionLying;

  /// Cuff-arm option when recording a reading.
  ///
  /// In en, this message translates to:
  /// **'Left arm'**
  String get cuffArmLeft;

  /// Cuff-arm option when recording a reading.
  ///
  /// In en, this message translates to:
  /// **'Right arm'**
  String get cuffArmRight;

  /// App bar title of the record-reading screen when adding.
  ///
  /// In en, this message translates to:
  /// **'Add reading'**
  String get recordBpTitleAdd;

  /// App bar title of the record-reading screen when editing.
  ///
  /// In en, this message translates to:
  /// **'Edit reading'**
  String get recordBpTitleEdit;

  /// Section header above the systolic/diastolic fields.
  ///
  /// In en, this message translates to:
  /// **'MEASUREMENT · REQUIRED'**
  String get recordSectionRequired;

  /// Section header above the optional fields.
  ///
  /// In en, this message translates to:
  /// **'OPTIONAL'**
  String get recordSectionOptional;

  /// Field label for the systolic input.
  ///
  /// In en, this message translates to:
  /// **'Systolic (mmHg)'**
  String get recordSystolicLabel;

  /// Field label for the diastolic input.
  ///
  /// In en, this message translates to:
  /// **'Diastolic (mmHg)'**
  String get recordDiastolicLabel;

  /// Field label for the optional pulse input.
  ///
  /// In en, this message translates to:
  /// **'Pulse (optional, bpm)'**
  String get recordPulseLabel;

  /// Field label for the optional cuff-arm dropdown.
  ///
  /// In en, this message translates to:
  /// **'Cuff arm (optional)'**
  String get recordCuffArmLabel;

  /// Hint text for the optional free-text notes field.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get recordNotesHint;

  /// Caption under the systolic/diastolic fields clarifying that the accepted range is an input check, not a medical assessment (PROJECT_SPEC.md §7).
  ///
  /// In en, this message translates to:
  /// **'Accepted range {sysMin}–{sysMax} / {diaMin}–{diaMax} mmHg. Range limits are input checks, not an assessment.'**
  String recordAcceptedRange(int sysMin, int sysMax, int diaMin, int diaMax);

  /// Submit button when adding a new reading.
  ///
  /// In en, this message translates to:
  /// **'Save reading'**
  String get recordSaveReading;

  /// Submit button when editing an existing reading.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get recordSaveChanges;

  /// Source tag on a reading that came from a scanned/imported report (PROJECT_SPEC.md §12). Must stay distinguishable from a manually entered reading.
  ///
  /// In en, this message translates to:
  /// **'Imported Report'**
  String get importedReportTag;

  /// Tooltip on the History screen's add-reading FAB.
  ///
  /// In en, this message translates to:
  /// **'Record BP'**
  String get historyRecordFabTooltip;

  /// Sort toggle tooltip; tapping switches to oldest first.
  ///
  /// In en, this message translates to:
  /// **'Sort: newest first'**
  String get historySortNewestFirst;

  /// Sort toggle tooltip; tapping switches to newest first.
  ///
  /// In en, this message translates to:
  /// **'Sort: oldest first'**
  String get historySortOldestFirst;

  /// Snackbar shown when the History export button is tapped (feature not built here).
  ///
  /// In en, this message translates to:
  /// **'Export isn\'t available yet.'**
  String get historyExportUnavailable;

  /// Empty state on the History screen.
  ///
  /// In en, this message translates to:
  /// **'No readings yet. Tap + to record your first blood pressure reading.'**
  String get historyEmpty;

  /// Shown when a History filter matches none of the recorded readings.
  ///
  /// In en, this message translates to:
  /// **'No readings match this filter.'**
  String get historyEmptyFiltered;

  /// History filter chip that shows every reading.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get historyFilterAll;

  /// History filter chip limiting the list to readings that have a note.
  ///
  /// In en, this message translates to:
  /// **'With notes'**
  String get historyFilterWithNotes;

  /// Uppercase prefix marking today's group in the History list.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get historyDayHeaderTodayPrefix;

  /// Confirmation dialog title for deleting a reading from History.
  ///
  /// In en, this message translates to:
  /// **'Delete this reading?'**
  String get historyDeleteTitle;

  /// Pulse portion of a History row subtitle.
  ///
  /// In en, this message translates to:
  /// **'{pulse} bpm'**
  String historySubtitlePulse(int pulse);

  /// Shown in a History row subtitle when the only extra detail is a free-text note.
  ///
  /// In en, this message translates to:
  /// **'Note added'**
  String get historySubtitleNoteAdded;

  /// App bar title of the single-reading detail screen.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get readingDetailTitle;

  /// Shown when a reading detail screen is opened for a reading that has been deleted.
  ///
  /// In en, this message translates to:
  /// **'This reading no longer exists.'**
  String get readingDetailNotFound;

  /// Row label for the pulse value on the reading detail screen.
  ///
  /// In en, this message translates to:
  /// **'Pulse'**
  String get readingDetailPulseLabel;

  /// Row label for the body-position value on the reading detail screen.
  ///
  /// In en, this message translates to:
  /// **'Body position'**
  String get readingDetailBodyPositionLabel;

  /// Row label for the cuff-arm value on the reading detail screen.
  ///
  /// In en, this message translates to:
  /// **'Cuff arm'**
  String get readingDetailCuffArmLabel;

  /// Row label for the measurement-context tags on the reading detail screen.
  ///
  /// In en, this message translates to:
  /// **'Context'**
  String get readingDetailContextLabel;

  /// Row label describing how the reading was entered.
  ///
  /// In en, this message translates to:
  /// **'Entered'**
  String get readingDetailEnteredLabel;

  /// Row value when a reading was typed in by hand (contrast with 'Imported Report').
  ///
  /// In en, this message translates to:
  /// **'Manually'**
  String get readingDetailEnteredManually;

  /// Section label above the free-text note on the reading detail screen.
  ///
  /// In en, this message translates to:
  /// **'NOTE'**
  String get readingDetailNoteLabel;

  /// Heading of the small comparison chart of the user's recent readings in the same morning/evening bucket.
  ///
  /// In en, this message translates to:
  /// **'SAME TIME OF DAY, LAST {count}'**
  String readingDetailSameTimeOfDayHeading(int count);

  /// Caption under the same-time-of-day comparison chart when the bucket is morning.
  ///
  /// In en, this message translates to:
  /// **'Systolic values, morning readings only.'**
  String get readingDetailSameTimeOfDayCaptionMorning;

  /// Caption under the same-time-of-day comparison chart when the bucket is evening.
  ///
  /// In en, this message translates to:
  /// **'Systolic values, evening readings only.'**
  String get readingDetailSameTimeOfDayCaptionEvening;

  /// Empty state on the Trends screen for the selected period.
  ///
  /// In en, this message translates to:
  /// **'No readings in this period yet.'**
  String get trendsEmpty;

  /// Compact label on a Trends period-selector chip.
  ///
  /// In en, this message translates to:
  /// **'{period, select, sevenDays{7 d} thirtyDays{30 d} ninetyDays{90 d} oneYear{1 y} other{All}}'**
  String trendsChipPeriod(String period);

  /// Full name of a trend period, used in stat subtitles.
  ///
  /// In en, this message translates to:
  /// **'{period, select, sevenDays{7 days} thirtyDays{30 days} ninetyDays{90 days} oneYear{1 year} other{All time}}'**
  String trendsPeriodName(String period);

  /// Label on the button that shares a PDF summary of the selected trend period.
  ///
  /// In en, this message translates to:
  /// **'Export {period} summary (PDF)'**
  String trendsExportButton(String period);

  /// Adjective form of a trend period, interpolated into trendsExportButton.
  ///
  /// In en, this message translates to:
  /// **'{period, select, sevenDays{7-day} thirtyDays{30-day} ninetyDays{90-day} oneYear{1-year} other{all-time}}'**
  String trendsExportPeriodName(String period);

  /// Header above the systolic/diastolic line chart on Trends.
  ///
  /// In en, this message translates to:
  /// **'SYSTOLIC / DIASTOLIC · mmHg'**
  String get trendsChartHeader;

  /// Chart legend label for the systolic line on Trends.
  ///
  /// In en, this message translates to:
  /// **'Systolic'**
  String get trendsLegendSystolic;

  /// Chart legend label for the diastolic line on Trends.
  ///
  /// In en, this message translates to:
  /// **'Diastolic'**
  String get trendsLegendDiastolic;

  /// Screen-reader description of the Trends systolic/diastolic chart.
  ///
  /// In en, this message translates to:
  /// **'Blood pressure trend chart. See the summary below for averages and reading count.'**
  String get trendsChartSemantics;

  /// Screen-reader description of the Trends pulse chart.
  ///
  /// In en, this message translates to:
  /// **'Pulse trend chart. See the summary below for averages.'**
  String get trendsPulseChartSemantics;

  /// Heading above the optional pulse chart on Trends.
  ///
  /// In en, this message translates to:
  /// **'Pulse'**
  String get trendsPulseSectionTitle;

  /// Stat-tile label for the period average.
  ///
  /// In en, this message translates to:
  /// **'AVERAGE'**
  String get trendsStatAverage;

  /// Subtitle under the average stat tile.
  ///
  /// In en, this message translates to:
  /// **'mmHg · {period}'**
  String trendsStatAverageSubtitle(String period);

  /// Stat-tile label for the reading count.
  ///
  /// In en, this message translates to:
  /// **'READINGS'**
  String get trendsStatReadings;

  /// Subtitle under the readings stat tile: distinct days logged out of the period length.
  ///
  /// In en, this message translates to:
  /// **'on {days} of {periodDays} days'**
  String trendsStatReadingsSubtitle(int days, int periodDays);

  /// Stat-tile label for the systolic min–max range.
  ///
  /// In en, this message translates to:
  /// **'RANGE'**
  String get trendsStatRange;

  /// Subtitle under the range stat tile.
  ///
  /// In en, this message translates to:
  /// **'systolic, mmHg'**
  String get trendsStatRangeSubtitle;

  /// Stat-tile label comparing mean systolic before and after noon.
  ///
  /// In en, this message translates to:
  /// **'MORNING VS EVENING'**
  String get trendsStatMorningEvening;

  /// Subtitle under the morning-vs-evening stat tile.
  ///
  /// In en, this message translates to:
  /// **'mean systolic'**
  String get trendsStatMorningEveningSubtitle;

  /// Frames the period average as a record, never a new measurement (PROJECT_SPEC.md §23). Wording is approved; keep it faithful when translating.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Average of 1 recorded reading} other{Average of {count} recorded readings}}'**
  String trendsAverageOfReadings(int count);

  /// Non-diagnostic disclaimer under the Trends stat grid (PROJECT_SPEC.md §12). Approved wording; any change needs the §37 non-diagnostic-scope review.
  ///
  /// In en, this message translates to:
  /// **'Averages describe what you recorded. They are not an assessment of your blood pressure — share them with your clinician.'**
  String get trendsDisclaimer;

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

  /// Subtitle for the Export data row; opens the Export data screen.
  ///
  /// In en, this message translates to:
  /// **'PDF, CSV, or a full archive — your choice'**
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
