import 'package:flutter_test/flutter_test.dart';
import 'package:vitality/l10n/app_localizations.dart';

import '../support/pump_app.dart';

/// Guards the exact English wording of every medical-safety string that
/// PROJECT_SPEC.md §12–14, §21, §23–24, §27, §29 (and the feature spec's
/// §13–14) pin down. §36 externalization must not silently reword these;
/// any intentional change here still needs the §37 non-diagnostic-scope
/// review, and updating this test is the deliberate checkpoint for it.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppLocalizations l10n;
  setUpAll(() async => l10n = await loadAppLocalizations());

  test('BP status category labels (§21, §29)', () {
    expect(l10n.bpCategoryLooksGood, 'Looks good');
    expect(l10n.bpCategoryWorthKeepingAnEyeOn, 'Worth keeping an eye on');
    expect(l10n.bpCategoryHigherThanUsual, 'Higher than the usual range');
    expect(l10n.bpCategoryReadingIsHigh, 'This reading is high');
  });

  test('"Why am I seeing this?" explanation (§24)', () {
    expect(l10n.bpWhyAmISeeingThis, 'Why am I seeing this?');
    expect(
      l10n.bpExplanation(136, 84, '130–139', '80–89'),
      'Your recorded blood pressure was 136/84 mmHg. The systolic value '
      'falls within the 130–139 range and the diastolic value falls within '
      'the 80–89 range. This classification describes this recorded '
      'reading. It is not a diagnosis.',
    );
  });

  test('trend summary sentences (§12, §23)', () {
    expect(
      l10n.trendSummaryAvgSystolic('7 days', 128),
      'Your average systolic reading over the last 7 days was 128 mmHg.',
    );
    expect(
      l10n.trendSummaryAvgDiastolic('30 days', 82),
      'Your average diastolic reading over the last 30 days was 82 mmHg.',
    );
    expect(
      l10n.trendSummaryAvgPulse('90 days', 70),
      'Your average pulse over the last 90 days was 70 bpm.',
    );
    expect(
      l10n.trendSummaryAverageStatus(1, 'Looks good'),
      'Average status (1 reading): Looks good.',
    );
    expect(
      l10n.trendSummaryAverageStatus(20, 'Higher than the usual range'),
      'Average status (20 readings): Higher than the usual range.',
    );
    expect(
      l10n.trendSummaryReadingCount(1),
      'You recorded 1 reading during this period.',
    );
    expect(
      l10n.trendSummaryReadingCount(12),
      'You recorded 12 readings during this period.',
    );
    expect(l10n.trendSummaryPeriodAll, 'available history');
    expect(
      l10n.trendFrequencySame,
      'You recorded the same number of readings as last period.',
    );
    expect(
      l10n.trendFrequencyFewer,
      'You recorded fewer readings this period than last.',
    );
    expect(
      l10n.trendFrequencyMore,
      'You recorded more readings this period than last.',
    );
  });

  test('category-movement sentence (§27)', () {
    expect(
      l10n.trendCategoryMovement('higher', 'elevated'),
      'Your average recorded reading moved from the higher category to the '
      'elevated category.',
    );
  });

  test('on-screen trends disclaimer (§12)', () {
    expect(
      l10n.trendsDisclaimer,
      'Averages describe what you recorded. They are not an assessment of '
      'your blood pressure — share them with your clinician.',
    );
  });

  test('Trends PDF disclaimer (§12, §28)', () {
    expect(
      l10n.trendPdfDisclaimer,
      'This is a record of self-reported home readings. It does not '
      'diagnose or interpret your blood pressure. Share it with your '
      'healthcare professional.',
    );
  });

  test('trend report medical-safety wording (§12-14, §23, §25, §28)', () {
    // Replaces the old "Average status (N readings): this reading is high"
    // phrasing in the exported report with neutral, non-diagnostic framing.
    expect(
      l10n.trendReportContextLine,
      'Context: review this pattern with your healthcare professional.',
    );
    expect(
      l10n.trendReportForClinicianBody,
      'This report summarises blood pressure information that the user '
      'recorded or imported in Vitaly during the selected period. It can be '
      'shared with a qualified healthcare professional. Vitaly does not '
      'diagnose, treat, or interpret medical conditions.',
    );
    expect(
      l10n.trendReportPrivacyNotice,
      'This report contains personal health information. Share it only with '
      'people you trust.',
    );
    expect(
      l10n.trendReportDisclaimer,
      'The readings in this report were recorded or imported by the user in '
      'Vitaly, a personal tracking and record-keeping tool. This report does '
      'not provide a medical diagnosis and does not replace advice from a '
      'qualified healthcare professional.',
    );
  });

  test('"Average of N recorded readings" framing (§23)', () {
    expect(l10n.trendsAverageOfReadings(1), 'Average of 1 recorded reading');
    expect(l10n.trendsAverageOfReadings(20), 'Average of 20 recorded readings');
  });

  test('scan / OCR safety wording (feature spec §6, §13, §14)', () {
    expect(
      l10n.scanSheetBody,
      'Vitaly will look for blood pressure values, but you always review '
      'and confirm them before anything is saved.',
    );
    expect(
      l10n.reviewInstructions,
      'Review each detected reading. Only what you confirm and select is '
      'added to BP History.',
    );
    expect(l10n.reviewOcrFailedTitle, "We couldn't reliably read this report.");
    expect(l10n.reviewNeedsReview, 'Needs review');
  });

  test('reminders / education non-diagnostic notes (§13, §15, §17, §23)', () {
    expect(
      l10n.remindersIntro,
      'Reminders prompt you to measure. Vitaly never asks you to change '
      'medication or treatment.',
    );
    expect(
      l10n.remindersFooter,
      'Notifications are delivered by Android. Silent hours are respected. '
      'Status colours describe delivery only, never your readings.',
    );
    expect(
      l10n.educationIntro,
      'General information about blood pressure and measurement. Not advice '
      'about your own readings.',
    );
    expect(
      l10n.articleDisclaimer,
      'This is general information, not personalized medical advice. If you '
      'feel unwell, contact a clinician or emergency services.',
    );
  });

  test('logging nudge never references reading values (§12-14)', () {
    final morning = l10n.loggingInsightMorningGap(2, 6);
    final evening = l10n.loggingInsightEveningGap(2, 6);
    for (final line in [morning, evening]) {
      expect(line.toLowerCase(), isNot(contains('mmHg'.toLowerCase())));
      expect(line, isNot(contains('systolic')));
      expect(line, isNot(contains('diastolic')));
      expect(line, isNot(contains('high')));
    }
    expect(
      morning,
      'You logged 2 of the last 7 mornings and 6 evenings. A morning '
      'reminder would even out the record.',
    );
    expect(
      evening,
      'You logged 2 of the last 7 evenings and 6 mornings. An evening '
      'reminder would even out the record.',
    );
  });
}
