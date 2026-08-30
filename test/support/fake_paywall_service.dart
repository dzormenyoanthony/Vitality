import 'package:vitality/core/paywall/paywall_service.dart';

/// Test double for [PaywallService]. Records every placement it was asked
/// to gate and, per [grantsAccess], either runs the gated callback (as
/// Superwall would after an already-entitled user or a successful
/// purchase) or leaves it unrun (as Superwall would on a dismissed
/// paywall) — letting tests assert both halves of the gating contract
/// without a real SDK.
final class FakePaywallService implements PaywallService {
  FakePaywallService({this.grantsAccess = true});

  final bool grantsAccess;
  final List<String> registeredPlacements = [];
  int identifyCallCount = 0;
  int resetCallCount = 0;

  @override
  Future<void> gateFeature({
    required String placement,
    required Future<void> Function() onAccessGranted,
    Map<String, Object>? params,
  }) async {
    registeredPlacements.add(placement);
    if (grantsAccess) await onAccessGranted();
  }

  @override
  Future<void> identify(String uid) async {
    identifyCallCount++;
  }

  @override
  Future<void> reset() async {
    resetCallCount++;
  }

  @override
  Future<bool> restorePurchases() async => grantsAccess;
}
