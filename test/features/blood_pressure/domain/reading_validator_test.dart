import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/blood_pressure/domain/reading_validator.dart';
import 'package:vitality/l10n/app_localizations.dart';

import '../../../support/pump_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppLocalizations l10n;
  setUpAll(() async => l10n = await loadAppLocalizations());
  group('ReadingValidator.validateSystolic', () {
    test('rejects empty value', () {
      expect(ReadingValidator.validateSystolic(l10n, ''), isNotNull);
    });

    test('rejects non-numeric value', () {
      expect(ReadingValidator.validateSystolic(l10n, 'abc'), isNotNull);
    });

    test('rejects a value just below the minimum', () {
      expect(ReadingValidator.validateSystolic(l10n, '59'), isNotNull);
    });

    test('accepts the minimum boundary', () {
      expect(ReadingValidator.validateSystolic(l10n, '60'), isNull);
    });

    test('accepts the maximum boundary', () {
      expect(ReadingValidator.validateSystolic(l10n, '260'), isNull);
    });

    test('rejects a value just above the maximum', () {
      expect(ReadingValidator.validateSystolic(l10n, '261'), isNotNull);
    });

    test('error copy states a range, not a diagnosis', () {
      final message = ReadingValidator.validateSystolic(l10n, '999');
      expect(message, contains('between'));
      expect(message!.toLowerCase(), isNot(contains('hypertension')));
    });
  });

  group('ReadingValidator.validateDiastolic', () {
    test('rejects a value just below the minimum', () {
      expect(ReadingValidator.validateDiastolic(l10n, '29'), isNotNull);
    });

    test('accepts the minimum boundary', () {
      expect(ReadingValidator.validateDiastolic(l10n, '30'), isNull);
    });

    test('accepts the maximum boundary', () {
      expect(ReadingValidator.validateDiastolic(l10n, '150'), isNull);
    });

    test('rejects a value just above the maximum', () {
      expect(ReadingValidator.validateDiastolic(l10n, '151'), isNotNull);
    });
  });

  group('ReadingValidator.validatePulse', () {
    test('accepts an empty value (optional field)', () {
      expect(ReadingValidator.validatePulse(l10n, ''), isNull);
    });

    test('rejects a value just below the minimum', () {
      expect(ReadingValidator.validatePulse(l10n, '29'), isNotNull);
    });

    test('accepts the minimum boundary', () {
      expect(ReadingValidator.validatePulse(l10n, '30'), isNull);
    });

    test('accepts the maximum boundary', () {
      expect(ReadingValidator.validatePulse(l10n, '220'), isNull);
    });

    test('rejects a value just above the maximum', () {
      expect(ReadingValidator.validatePulse(l10n, '221'), isNotNull);
    });
  });
}
