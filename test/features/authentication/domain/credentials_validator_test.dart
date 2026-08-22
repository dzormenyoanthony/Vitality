import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/authentication/domain/credentials_validator.dart';

void main() {
  group('CredentialsValidator.validateEmail', () {
    test('rejects empty email', () {
      expect(CredentialsValidator.validateEmail(''), isNotNull);
    });

    test('rejects malformed email', () {
      expect(CredentialsValidator.validateEmail('not-an-email'), isNotNull);
    });

    test('accepts a well-formed email', () {
      expect(CredentialsValidator.validateEmail('user@example.com'), isNull);
    });
  });

  group('CredentialsValidator.validatePassword', () {
    test('rejects empty password', () {
      expect(CredentialsValidator.validatePassword(''), isNotNull);
    });

    test('rejects password shorter than the minimum', () {
      expect(CredentialsValidator.validatePassword('12345'), isNotNull);
    });

    test('accepts a password meeting the minimum length', () {
      expect(CredentialsValidator.validatePassword('123456'), isNull);
    });
  });

  group('CredentialsValidator.validatePreferredName', () {
    test('rejects empty name', () {
      expect(CredentialsValidator.validatePreferredName('  '), isNotNull);
    });

    test('accepts a non-empty name', () {
      expect(CredentialsValidator.validatePreferredName('Alex'), isNull);
    });
  });
}
