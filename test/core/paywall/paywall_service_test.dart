import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/core/paywall/paywall_service.dart';

void main() {
  group('NoOpPaywallService', () {
    test('grants access immediately without blocking the caller', () async {
      const service = NoOpPaywallService();
      var ran = false;

      await service.gateFeature(
        placement: 'scan_report',
        onAccessGranted: () async {
          ran = true;
        },
      );

      expect(ran, isTrue);
    });

    test('identify, reset, and restorePurchases are safe no-ops', () async {
      const service = NoOpPaywallService();

      await service.identify('uid');
      await service.reset();

      expect(await service.restorePurchases(), isFalse);
    });
  });
}
