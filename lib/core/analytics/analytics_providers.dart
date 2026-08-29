import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'analytics_service.dart';

/// The app's [AnalyticsService]. Defaults to a no-op; `main.dart` overrides
/// it with a `FirebaseAnalyticsService` once Firebase has initialized, and
/// tests override it with a fake.
final analyticsServiceProvider = Provider<AnalyticsService>(
  (ref) => const NoOpAnalyticsService(),
);
