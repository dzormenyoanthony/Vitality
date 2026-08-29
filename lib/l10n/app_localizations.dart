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
