import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/authentication/domain/credentials_validator.dart';
import 'package:vitality/l10n/app_localizations.dart';

import '../../../support/pump_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppLocalizations l10n;
  setUpAll(() async => l10n = await loadAppLocalizations());
  group('CredentialsValidator.validateEmail', () {
    test('rejects empty email', () {
      expect(CredentialsValidator.validateEmail(l10n, ''), isNotNull);
    });

    test('rejects malformed email', () {
      expect(CredentialsValidator.validateEmail(l10n, 'not-an-email'), isNotNull);
    });

    test('accepts a well-formed email', () {
      expect(CredentialsValidator.validateEmail(l10n, 'user@example.com'), isNull);
    });
  });

  group('CredentialsValidator.validatePassword', () {
    test('rejects empty password', () {
      expect(CredentialsValidator.validatePassword(l10n, ''), isNotNull);
    });

    test('rejects password shorter than the minimum', () {
      expect(CredentialsValidator.validatePassword(l10n, '12345'), isNotNull);
    });

    test('accepts a password meeting the minimum length', () {
      expect(CredentialsValidator.validatePassword(l10n, '123456'), isNull);
    });
  });

  group('CredentialsValidator.validatePreferredName', () {
    test('rejects empty name', () {
      expect(CredentialsValidator.validatePreferredName(l10n, '  '), isNotNull);
    });

    test('accepts a non-empty name', () {
      expect(CredentialsValidator.validatePreferredName(l10n, 'Alex'), isNull);
    });
  });
}
