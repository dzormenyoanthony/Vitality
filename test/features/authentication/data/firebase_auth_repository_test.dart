import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/core/errors/failure.dart';
import 'package:vitality/features/authentication/data/firebase_auth_repository.dart';

void main() {
  group('mapFirebaseAuthException', () {
    test('maps email-already-in-use to a ValidationFailure', () {
      final failure = mapFirebaseAuthException(
        FirebaseAuthException(code: 'email-already-in-use'),
      );
      expect(failure, isA<ValidationFailure>());
    });

    test('maps wrong-password to a generic incorrect-credentials message', () {
      final failure = mapFirebaseAuthException(
        FirebaseAuthException(code: 'wrong-password'),
      );
      expect(failure.message, 'Incorrect email or password.');
    });

    test('maps network-request-failed to a NetworkFailure', () {
      final failure = mapFirebaseAuthException(
        FirebaseAuthException(code: 'network-request-failed'),
      );
      expect(failure, isA<NetworkFailure>());
    });

    test('maps unknown codes to UnexpectedFailure rather than leaking them', () {
      final failure = mapFirebaseAuthException(
        FirebaseAuthException(code: 'some-unmapped-code'),
      );
      expect(failure, isA<UnexpectedFailure>());
    });
  });
}
