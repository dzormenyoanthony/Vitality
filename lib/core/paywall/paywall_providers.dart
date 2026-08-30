import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'paywall_service.dart';

/// The app's [PaywallService]. Defaults to a no-op (grants every premium
/// action immediately); `main.dart` overrides it with a
/// `SuperwallPaywallService` once the SDK has been configured, and tests
/// keep the default or override with their own fake.
final paywallServiceProvider = Provider<PaywallService>(
  (ref) => const NoOpPaywallService(),
);
