import 'package:flutter_test/flutter_test.dart';
import 'package:vitality/l10n/app_localizations.dart';

import 'package:vitality/features/blood_pressure/domain/bp_classification.dart';
import 'package:vitality/features/blood_pressure/domain/bp_classification_service.dart';

import '../../../support/pump_app.dart';

BPCategory _classify(int systolic, int diastolic) =>
    BPClassificationService.classify(systolic: systolic, diastolic: diastolic).category;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppLocalizations l10n;
  setUpAll(() async => l10n = await loadAppLocalizations());

  group('BPClassificationService.classify', () {
    // The exact boundary values mandated by PROJECT_SPEC.md §32.
    test('boundary values match the spec exactly', () {
      expect(_classify(119, 79), BPCategory.normal);
      expect(_classify(120, 79), BPCategory.elevated);
      expect(_classify(129, 79), BPCategory.elevated);
      expect(_classify(130, 79), BPCategory.higher);
      expect(_classify(130, 80), BPCategory.higher);
      expect(_classify(139, 89), BPCategory.higher);
      expect(_classify(140, 89), BPCategory.high);
      expect(_classify(139, 90), BPCategory.high);
    });

    test('a fully normal reading is normal', () {
      expect(_classify(110, 70), BPCategory.normal);
    });

    test('systolic-only elevation with normal diastolic is elevated', () {
      expect(_classify(125, 75), BPCategory.elevated);
    });

    test('diastolic reaching 80 with a normal systolic is higher, not elevated', () {
      // There is no diastolic-only "elevated" tier (PROJECT_SPEC.md §19).
      expect(_classify(110, 82), BPCategory.higher);
    });

    test('mixed categories use the higher applicable one (spec example 128/86)', () {
      // Systolic 128 -> elevated; diastolic 86 -> higher. Overall: higher.
      expect(_classify(128, 86), BPCategory.higher);
    });

    test('a high systolic overrides a lower diastolic category', () {
      expect(_classify(150, 70), BPCategory.high);
    });

    test('a high diastolic overrides a lower systolic category', () {
      expect(_classify(115, 95), BPCategory.high);
    });

    test('never averages systolic and diastolic together', () {
      // Averaging (160+60)/2 = 110 would read as normal; the actual
      // classification must be driven by the high systolic alone.
      expect(_classify(160, 60), BPCategory.high);
    });

    test('classification is deterministic across repeated calls', () {
      final first = BPClassificationService.classify(systolic: 132, diastolic: 84);
      final second = BPClassificationService.classify(systolic: 132, diastolic: 84);
      expect(first.category, second.category);
      expect(first.systolicRangeLabel, second.systolicRangeLabel);
      expect(first.diastolicRangeLabel, second.diastolicRangeLabel);
    });

    test('classifying a calculated average pair works the same as a single reading', () {
      // The service has no notion of "average" — that framing belongs to
      // the caller (PROJECT_SPEC.md §23); rounded average values classify
      // exactly like any other pair.
      const roundedAverageSystolic = 136;
      const roundedAverageDiastolic = 84;
      expect(_classify(roundedAverageSystolic, roundedAverageDiastolic), BPCategory.higher);
    });

    test('label text matches the approved non-diagnostic wording', () {
      expect(BPCategory.normal.label(l10n), 'Looks good');
      expect(BPCategory.elevated.label(l10n), 'Worth keeping an eye on');
      expect(BPCategory.higher.label(l10n), 'Higher than the usual range');
      expect(BPCategory.high.label(l10n), 'This reading is high');
    });

    test('explanation is generated from the classification data and is non-diagnostic', () {
      final classification = BPClassificationService.classify(systolic: 136, diastolic: 84);
      final explanation = classification.explanation(l10n);

      expect(explanation, contains('136/84 mmHg'));
      expect(explanation, contains('not a diagnosis'));
      for (final forbidden in [
        'hypertension',
        'you have',
        'you are unhealthy',
        'you need medication',
      ]) {
        expect(explanation.toLowerCase(), isNot(contains(forbidden)));
      }
    });
  });
}
