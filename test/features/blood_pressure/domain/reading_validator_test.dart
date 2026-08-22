import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/blood_pressure/domain/reading_validator.dart';

void main() {
  group('ReadingValidator.validateSystolic', () {
    test('rejects empty value', () {
      expect(ReadingValidator.validateSystolic(''), isNotNull);
    });

    test('rejects non-numeric value', () {
      expect(ReadingValidator.validateSystolic('abc'), isNotNull);
    });

    test('rejects a value just below the minimum', () {
      expect(ReadingValidator.validateSystolic('59'), isNotNull);
    });

    test('accepts the minimum boundary', () {
      expect(ReadingValidator.validateSystolic('60'), isNull);
    });

    test('accepts the maximum boundary', () {
      expect(ReadingValidator.validateSystolic('260'), isNull);
    });

    test('rejects a value just above the maximum', () {
      expect(ReadingValidator.validateSystolic('261'), isNotNull);
    });

    test('error copy states a range, not a diagnosis', () {
      final message = ReadingValidator.validateSystolic('999');
      expect(message, contains('between'));
      expect(message!.toLowerCase(), isNot(contains('hypertension')));
    });
  });

  group('ReadingValidator.validateDiastolic', () {
    test('rejects a value just below the minimum', () {
      expect(ReadingValidator.validateDiastolic('29'), isNotNull);
    });

    test('accepts the minimum boundary', () {
      expect(ReadingValidator.validateDiastolic('30'), isNull);
    });

    test('accepts the maximum boundary', () {
      expect(ReadingValidator.validateDiastolic('150'), isNull);
    });

    test('rejects a value just above the maximum', () {
      expect(ReadingValidator.validateDiastolic('151'), isNotNull);
    });
  });

  group('ReadingValidator.validatePulse', () {
    test('accepts an empty value (optional field)', () {
      expect(ReadingValidator.validatePulse(''), isNull);
    });

    test('rejects a value just below the minimum', () {
      expect(ReadingValidator.validatePulse('29'), isNotNull);
    });

    test('accepts the minimum boundary', () {
      expect(ReadingValidator.validatePulse('30'), isNull);
    });

    test('accepts the maximum boundary', () {
      expect(ReadingValidator.validatePulse('220'), isNull);
    });

    test('rejects a value just above the maximum', () {
      expect(ReadingValidator.validatePulse('221'), isNotNull);
    });
  });
}
