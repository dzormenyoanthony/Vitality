/// Centralized premium-access/paywall layer (CLAUDE.md §19, superwall_paywall.md
/// "ARCHITECTURE REQUIREMENTS"). Every premium action in the app calls
/// [gateFeature] instead of talking to the paywall SDK directly, so access
/// logic lives in exactly one place and can't be bypassed by adding a new
/// entry point that forgets to check it.
///
/// An abstraction (like [AnalyticsService]) so the backend can be swapped
/// and so widget tests never need a real platform-channel-backed SDK.
abstract interface class PaywallService {
  /// Registers [placement] with the paywall SDK and gates [onAccessGranted]
  /// behind it:
  /// - If the user already has premium access, or grants it by completing
  ///   a purchase presented for this placement, [onAccessGranted] runs.
  /// - If the paywall is dismissed without access being granted, or the
  ///   placement isn't attached to a paywall at all yet, the SDK decides
  ///   whether the feature is gated; [onAccessGranted] only runs when it
  ///   grants access.
  ///
  /// [params] are optional key/value pairs made available to campaign
  /// rules/paywall copy on the Superwall dashboard.
  Future<void> gateFeature({
    required String placement,
    required Future<void> Function() onAccessGranted,
    Map<String, Object>? params,
  });

  /// Associates the paywall SDK's user with the signed-in Firebase [uid] so
  /// entitlement state is tied to the right account and survives app
  /// restarts/reinstalls tied to that account.
  Future<void> identify(String uid);

  /// Clears the identified user (e.g. on sign-out) so the next signed-in
  /// account doesn't inherit the previous one's cached entitlement state
  /// on a shared device.
  Future<void> reset();

  /// Restores a previous purchase (e.g. after a reinstall). Returns whether
  /// an active entitlement was found.
  Future<bool> restorePurchases();
}

/// Default implementation: always grants access immediately, never shows a
/// paywall. Used when Superwall isn't configured (CLAUDE.md §20: a missing
/// third-party integration must degrade, not crash or silently block core
/// use) and as the base for test fakes, so existing feature tests don't
/// need a real SDK to exercise the flows a paywall would otherwise gate.
final class NoOpPaywallService implements PaywallService {
  const NoOpPaywallService();

  @override
  Future<void> gateFeature({
    required String placement,
    required Future<void> Function() onAccessGranted,
    Map<String, Object>? params,
  }) => onAccessGranted();

  @override
  Future<void> identify(String uid) async {}

  @override
  Future<void> reset() async {}

  @override
  Future<bool> restorePurchases() async => false;
}
