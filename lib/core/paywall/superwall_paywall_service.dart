import 'package:superwallkit_flutter/superwallkit_flutter.dart';

import '../utils/logger.dart';
import 'paywall_service.dart';

/// [PaywallService] backed by the Superwall Flutter SDK. Requires
/// `Superwall.configure(...)` to already have been called (see
/// `main.dart`) before any instance method is used.
final class SuperwallPaywallService implements PaywallService {
  const SuperwallPaywallService();

  @override
  Future<void> gateFeature({
    required String placement,
    required Future<void> Function() onAccessGranted,
    Map<String, Object>? params,
  }) {
    final handler = PaywallPresentationHandler()
      ..onError((error) {
        AppLogger.error('Superwall paywall error for "$placement"', error: error);
      });

    return Superwall.shared.registerPlacement(
      placement,
      params: params,
      handler: handler,
      feature: () {
        onAccessGranted();
      },
    );
  }

  @override
  Future<void> identify(String uid) => Superwall.shared.identify(uid);

  @override
  Future<void> reset() => Superwall.shared.reset();

  @override
  Future<bool> restorePurchases() async {
    final result = await Superwall.shared.restorePurchases();
    return result is RestorationResultRestored;
  }
}
