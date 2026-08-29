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
  String get commonNone => 'None';

  @override
  String get commonChange => 'Change';

  @override
  String get commonNotSet => 'Not set';

  @override
  String get commonSaving => 'Saving';

  @override
  String get commonExport => 'Export';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonCannotBeUndone => 'This cannot be undone.';

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
  String get remindersTitle => 'Reminders';

  @override
  String get remindersEveryDay => 'Every day';

  @override
  String get remindersIntro =>
      'Reminders prompt you to measure. Vitaly never asks you to change medication or treatment.';

  @override
  String get remindersEmpty => 'No reminders yet.';

  @override
  String get remindersAddButton => 'Add reminder';

  @override
  String get remindersFooter =>
      'Notifications are delivered by Android. Silent hours are respected. Status colours describe delivery only, never your readings.';

  @override
  String get remindersNotificationsOffPrefix =>
      'System notifications for Vitaly are switched off. ';

  @override
  String get remindersOpenAndroidSettings => 'Open Android settings';

  @override
  String get remindersDeleteTitle => 'Delete this reminder?';

  @override
  String remindersDeleteBody(String label) {
    return '\"$label\" will no longer remind you.';
  }

  @override
  String get remindersStatusOff => 'Off';

  @override
  String get remindersStatusDelivering => 'delivering';

  @override
  String remindersStatusSilenced(String range) {
    return 'silenced $range';
  }

  @override
  String get remindersNewReminderLabel => 'NEW REMINDER';

  @override
  String get remindersRepeatLabel => 'REPEAT';

  @override
  String get reminderFormTitleAdd => 'Add reminder';

  @override
  String get reminderFormTitleEdit => 'Edit reminder';

  @override
  String get reminderFormLabelField => 'Label';

  @override
  String get reminderFormLabelRequired => 'Enter a label.';

  @override
  String get reminderFormTimeLabel => 'Time';

  @override
  String get reminderFormRepeatOn => 'Repeat on';

  @override
  String get reminderFormQuietHours => 'Quiet hours (optional)';

  @override
  String get reminderFormQuietHoursHelp =>
      'If this reminder\'s time falls in this window, it\'s delivered silently instead of not at all.';

  @override
  String get reminderFormQuietFrom => 'From';

  @override
  String get reminderFormQuietUntil => 'Until';

  @override
  String get reminderFormClearQuietHours => 'Clear quiet hours';

  @override
  String get reminderFormSelectDay => 'Select at least one day.';

  @override
  String get reportCategoryBpReport => 'BP report';

  @override
  String get reportCategoryLabResults => 'Lab results';

  @override
  String get reportCategoryPrescriptions => 'Prescriptions';

  @override
  String get reportCategoryEcg => 'ECG';

  @override
  String get reportCategoryOther => 'Other';

  @override
  String get scanSheetBody =>
      'Vitaly will look for blood pressure values, but you always review and confirm them before anything is saved.';

  @override
  String get scanSheetCamera => 'Scan with camera';

  @override
  String get scanSheetImport => 'Import from device';

  @override
  String get scanSheetImportSubtitle => 'Image or PDF';

  @override
  String get scanScannerError =>
      'Couldn\'t open the scanner. Please try again.';

  @override
  String get scanImportError => 'Couldn\'t import that file. Please try again.';

  @override
  String get reportViewerFallbackTitle => 'Report';

  @override
  String get reportViewerNotFound => 'This report is no longer available.';

  @override
  String get reportViewerNoDocument =>
      'This report\'s original document isn\'t available on this device.';

  @override
  String get reportViewerPageOffline => 'This page isn\'t available offline.';

  @override
  String reportViewerPageIndicator(int page, int total) {
    return 'Page $page of $total';
  }

  @override
  String get savedReportsTitle => 'My saved reports';

  @override
  String get savedReportsEmpty =>
      'No saved reports yet. Scan or import a report to get started.';

  @override
  String get savedReportsEmptyCategory => 'No reports in this category yet.';

  @override
  String get savedReportsThisMonth => 'THIS MONTH';

  @override
  String get savedReportsEarlier => 'EARLIER';

  @override
  String get savedReportsLockerEyebrow => 'YOUR DOCUMENT LOCKER';

  @override
  String savedReportsLockerFilesSize(String size) {
    return 'files · $size';
  }

  @override
  String get savedReportsUpload => 'Upload report';

  @override
  String get savedReportsScanPage => 'Scan a page';

  @override
  String savedReportsCategoryAll(int count) {
    return 'All $count';
  }

  @override
  String savedReportsCategoryChip(String label, int count) {
    return '$label $count';
  }

  @override
  String get savedReportsTypePdf => 'PDF';

  @override
  String get savedReportsTypeImage => 'IMG';

  @override
  String get savedReportsEditDetails => 'Edit details';

  @override
  String get savedReportsFieldTitle => 'Title';

  @override
  String get savedReportsFieldCategory => 'Category';

  @override
  String get savedReportsFieldSource => 'Source (optional)';

  @override
  String get savedReportsDeleteTitle => 'Delete this report?';

  @override
  String get savedReportsDeleteBody =>
      'The saved document and its extracted information will be removed. This cannot be undone.';

  @override
  String get savedReportsFooter =>
      'Files stay on this device unless you share them. Attach any report to a reading from its detail view.';

  @override
  String get reviewTitle => 'Review extracted information';

  @override
  String reviewScannedReportTitle(String date) {
    return 'Scanned report – $date';
  }

  @override
  String get reviewReportSaved => 'Report saved.';

  @override
  String reviewReportSavedWithReadings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Report saved and $count readings added to BP History.',
      one: 'Report saved and 1 reading added to BP History.',
    );
    return '$_temp0';
  }

  @override
  String get reviewSaveWithoutInfo => 'Save report without extracted info';

  @override
  String get reviewConfirmAndSave => 'Confirm and save';

  @override
  String get reviewDocumentDetails => 'Document details';

  @override
  String get reviewSourceHint => 'e.g. Dr. Okafor, Northside Lab';

  @override
  String get reviewProcessing => 'Reading your report…';

  @override
  String get reviewOcrFailedTitle => 'We couldn\'t reliably read this report.';

  @override
  String get reviewOcrFailedBody =>
      'You can retry, or save the original document without extracted information — you can always add readings manually afterward.';

  @override
  String get reviewScanAgain => 'Scan or import again';

  @override
  String get reviewNoReadings =>
      'No blood pressure readings were detected. You can add one manually.';

  @override
  String get reviewInstructions =>
      'Review each detected reading. Only what you confirm and select is added to BP History.';

  @override
  String get reviewAddMissing => 'Add a missing reading';

  @override
  String reviewReadingValue(int systolic, int diastolic) {
    return '$systolic/$diastolic mmHg';
  }

  @override
  String get reviewNeedsReview => 'Needs review';

  @override
  String get reviewNoDate => 'No date detected';

  @override
  String get reviewChangeDate => 'Change date';

  @override
  String get articleCategoryBasics => 'Basics';

  @override
  String get articleCategoryMeasuringWell => 'Measuring well';

  @override
  String get articleCategoryWorkingWithClinician =>
      'Working with your clinician';

  @override
  String get educationTitle => 'Learn';

  @override
  String get educationIntro =>
      'General information about blood pressure and measurement. Not advice about your own readings.';

  @override
  String get educationFooter =>
      'Sources listed on each article. If you feel unwell, contact a clinician or emergency services.';

  @override
  String articleReadTimeMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String articleRowSubtitle(String summary, int minutes) {
    return '$summary · $minutes min';
  }

  @override
  String articleReviewedLine(int minutes, String date) {
    return '$minutes min read · Reviewed $date';
  }

  @override
  String articleDetailMetaLine(int minutes, String date) {
    return '$minutes min read · Reviewed $date · General information';
  }

  @override
  String get articleNotFound => 'This article is no longer available.';

  @override
  String articleSourceLine(String source) {
    return 'Source: $source';
  }

  @override
  String get articleDisclaimer =>
      'This is general information, not personalized medical advice. If you feel unwell, contact a clinician or emergency services.';

  @override
  String get measureWellBeforeYouMeasure => 'BEFORE YOU MEASURE';

  @override
  String get measureWellStep1 =>
      'Avoid caffeine, smoking and exercise for 30 minutes.';

  @override
  String get measureWellStep2 =>
      'Empty your bladder, then sit quietly for five minutes.';

  @override
  String get measureWellStep3 =>
      'Sit with your back supported and both feet flat on the floor.';

  @override
  String get measureWellCuffPlacement => 'CUFF PLACEMENT';

  @override
  String get measureWellCuffParagraph =>
      'Rest your arm on a table so the cuff sits level with your heart, with the cuff\'s lower edge about 2 cm above the elbow crease, snug but not tight, directly on skin rather than over clothing.';

  @override
  String get measureWellHeartLevel => 'heart level';

  @override
  String get measureWellElbowCallout => '2 cm above the elbow crease';

  @override
  String get measureWellDiagramCaption =>
      'Cuff centred over the artery, level with the heart.';

  @override
  String get measureWellDiagramReadingUnit => '82  mmHg';

  @override
  String get bpCategoryLooksGood => 'Looks good';

  @override
  String get bpCategoryWorthKeepingAnEyeOn => 'Worth keeping an eye on';

  @override
  String get bpCategoryHigherThanUsual => 'Higher than the usual range';

  @override
  String get bpCategoryReadingIsHigh => 'This reading is high';

  @override
  String get bpCategoryNameNormal => 'normal';

  @override
  String get bpCategoryNameElevated => 'elevated';

  @override
  String get bpCategoryNameHigher => 'higher';

  @override
  String get bpCategoryNameHigh => 'high';

  @override
  String bpExplanation(
    int systolic,
    int diastolic,
    String systolicRange,
    String diastolicRange,
  ) {
    return 'Your recorded blood pressure was $systolic/$diastolic mmHg. The systolic value falls within the $systolicRange range and the diastolic value falls within the $diastolicRange range. This classification describes this recorded reading. It is not a diagnosis.';
  }

  @override
  String get bpWhyAmISeeingThis => 'Why am I seeing this?';

  @override
  String bpStatusSemanticsLabel(String status) {
    return 'Status: $status';
  }

  @override
  String bpStatusSemanticsLabelInteractive(String status) {
    return 'Status: $status. Why am I seeing this?';
  }

  @override
  String trendSummaryAvgSystolic(String period, int value) {
    return 'Your average systolic reading over the last $period was $value mmHg.';
  }

  @override
  String trendSummaryAvgDiastolic(String period, int value) {
    return 'Your average diastolic reading over the last $period was $value mmHg.';
  }

  @override
  String trendSummaryAvgPulse(String period, int value) {
    return 'Your average pulse over the last $period was $value bpm.';
  }

  @override
  String trendSummaryAverageStatus(int count, String status) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Average status ($count readings): $status.',
      one: 'Average status (1 reading): $status.',
    );
    return '$_temp0';
  }

  @override
  String trendSummaryReadingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You recorded $count readings during this period.',
      one: 'You recorded 1 reading during this period.',
    );
    return '$_temp0';
  }

  @override
  String get trendSummaryPeriodAll => 'available history';

  @override
  String trendCategoryMovement(String previous, String current) {
    return 'Your average recorded reading moved from the $previous category to the $current category.';
  }

  @override
  String get trendFrequencySame =>
      'You recorded the same number of readings as last period.';

  @override
  String get trendFrequencyFewer =>
      'You recorded fewer readings this period than last.';

  @override
  String get trendFrequencyMore =>
      'You recorded more readings this period than last.';

  @override
  String get trendPdfTitle => 'Vitaly - Trend Summary';

  @override
  String trendPdfGenerated(String date) {
    return 'Generated $date';
  }

  @override
  String get trendPdfReadingsHeader => 'Readings in this period';

  @override
  String get trendPdfColDate => 'Date';

  @override
  String get trendPdfColTime => 'Time';

  @override
  String get trendPdfColSystolic => 'Systolic';

  @override
  String get trendPdfColDiastolic => 'Diastolic';

  @override
  String get trendPdfColPulse => 'Pulse';

  @override
  String get trendPdfDisclaimer =>
      'This is a record of self-reported home readings. It does not diagnose or interpret your blood pressure. Share it with your healthcare professional.';

  @override
  String loggingInsightMorningGap(int morningDays, int eveningDays) {
    return 'You logged $morningDays of the last 7 mornings and $eveningDays evenings. A morning reminder would even out the record.';
  }

  @override
  String loggingInsightEveningGap(int eveningDays, int morningDays) {
    return 'You logged $eveningDays of the last 7 evenings and $morningDays mornings. An evening reminder would even out the record.';
  }

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
  String get contextMorning => 'Morning';

  @override
  String get contextEvening => 'Evening';

  @override
  String get contextBeforeMedication => 'Before medication';

  @override
  String get contextAfterMedication => 'After medication';

  @override
  String get contextAfterExercise => 'After exercise';

  @override
  String get contextAfterMeal => 'After meal';

  @override
  String get contextOther => 'Other';

  @override
  String get bodyPositionSitting => 'Sitting';

  @override
  String get bodyPositionStanding => 'Standing';

  @override
  String get bodyPositionLying => 'Lying down';

  @override
  String get cuffArmLeft => 'Left arm';

  @override
  String get cuffArmRight => 'Right arm';

  @override
  String get recordBpTitleAdd => 'Add reading';

  @override
  String get recordBpTitleEdit => 'Edit reading';

  @override
  String get recordSectionRequired => 'MEASUREMENT · REQUIRED';

  @override
  String get recordSectionOptional => 'OPTIONAL';

  @override
  String get recordSystolicLabel => 'Systolic (mmHg)';

  @override
  String get recordDiastolicLabel => 'Diastolic (mmHg)';

  @override
  String get recordPulseLabel => 'Pulse (optional, bpm)';

  @override
  String get recordCuffArmLabel => 'Cuff arm (optional)';

  @override
  String get recordNotesHint => 'Notes';

  @override
  String recordAcceptedRange(int sysMin, int sysMax, int diaMin, int diaMax) {
    return 'Accepted range $sysMin–$sysMax / $diaMin–$diaMax mmHg. Range limits are input checks, not an assessment.';
  }

  @override
  String get recordSaveReading => 'Save reading';

  @override
  String get recordSaveChanges => 'Save changes';

  @override
  String get importedReportTag => 'Imported Report';

  @override
  String get historyRecordFabTooltip => 'Record BP';

  @override
  String get historySortNewestFirst => 'Sort: newest first';

  @override
  String get historySortOldestFirst => 'Sort: oldest first';

  @override
  String get historyExportUnavailable => 'Export isn\'t available yet.';

  @override
  String get historyEmpty =>
      'No readings yet. Tap + to record your first blood pressure reading.';

  @override
  String get historyEmptyFiltered => 'No readings match this filter.';

  @override
  String get historyFilterAll => 'All';

  @override
  String get historyFilterWithNotes => 'With notes';

  @override
  String get historyDayHeaderTodayPrefix => 'TODAY';

  @override
  String get historyDeleteTitle => 'Delete this reading?';

  @override
  String historySubtitlePulse(int pulse) {
    return '$pulse bpm';
  }

  @override
  String get historySubtitleNoteAdded => 'Note added';

  @override
  String get readingDetailTitle => 'Reading';

  @override
  String get readingDetailNotFound => 'This reading no longer exists.';

  @override
  String get readingDetailPulseLabel => 'Pulse';

  @override
  String get readingDetailBodyPositionLabel => 'Body position';

  @override
  String get readingDetailCuffArmLabel => 'Cuff arm';

  @override
  String get readingDetailContextLabel => 'Context';

  @override
  String get readingDetailEnteredLabel => 'Entered';

  @override
  String get readingDetailEnteredManually => 'Manually';

  @override
  String get readingDetailNoteLabel => 'NOTE';

  @override
  String readingDetailSameTimeOfDayHeading(int count) {
    return 'SAME TIME OF DAY, LAST $count';
  }

  @override
  String get readingDetailSameTimeOfDayCaptionMorning =>
      'Systolic values, morning readings only.';

  @override
  String get readingDetailSameTimeOfDayCaptionEvening =>
      'Systolic values, evening readings only.';

  @override
  String get trendsEmpty => 'No readings in this period yet.';

  @override
  String trendsChipPeriod(String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'sevenDays': '7 d',
      'thirtyDays': '30 d',
      'ninetyDays': '90 d',
      'oneYear': '1 y',
      'other': 'All',
    });
    return '$_temp0';
  }

  @override
  String trendsPeriodName(String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'sevenDays': '7 days',
      'thirtyDays': '30 days',
      'ninetyDays': '90 days',
      'oneYear': '1 year',
      'other': 'All time',
    });
    return '$_temp0';
  }

  @override
  String trendsExportButton(String period) {
    return 'Export $period summary (PDF)';
  }

  @override
  String trendsExportPeriodName(String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'sevenDays': '7-day',
      'thirtyDays': '30-day',
      'ninetyDays': '90-day',
      'oneYear': '1-year',
      'other': 'all-time',
    });
    return '$_temp0';
  }

  @override
  String get trendsChartHeader => 'SYSTOLIC / DIASTOLIC · mmHg';

  @override
  String get trendsLegendSystolic => 'Systolic';

  @override
  String get trendsLegendDiastolic => 'Diastolic';

  @override
  String get trendsChartSemantics =>
      'Blood pressure trend chart. See the summary below for averages and reading count.';

  @override
  String get trendsPulseChartSemantics =>
      'Pulse trend chart. See the summary below for averages.';

  @override
  String get trendsPulseSectionTitle => 'Pulse';

  @override
  String get trendsStatAverage => 'AVERAGE';

  @override
  String trendsStatAverageSubtitle(String period) {
    return 'mmHg · $period';
  }

  @override
  String get trendsStatReadings => 'READINGS';

  @override
  String trendsStatReadingsSubtitle(int days, int periodDays) {
    return 'on $days of $periodDays days';
  }

  @override
  String get trendsStatRange => 'RANGE';

  @override
  String get trendsStatRangeSubtitle => 'systolic, mmHg';

  @override
  String get trendsStatMorningEvening => 'MORNING VS EVENING';

  @override
  String get trendsStatMorningEveningSubtitle => 'mean systolic';

  @override
  String trendsAverageOfReadings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Average of $count recorded readings',
      one: 'Average of 1 recorded reading',
    );
    return '$_temp0';
  }

  @override
  String get trendsDisclaimer =>
      'Averages describe what you recorded. They are not an assessment of your blood pressure — share them with your clinician.';

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
