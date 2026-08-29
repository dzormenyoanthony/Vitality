/// Product analytics for the general funnel events listed in
/// PROJECT_SPEC.md §26. An abstraction (like [NotificationScheduler]) so
/// the backend can be swapped without touching feature code, and so tests
/// run against a fake.
///
/// Hard privacy rule (§26): no method here accepts an actual
/// blood-pressure value — `logBpReadingRecorded` takes only whether the
/// reading was imported, never systolic/diastolic/pulse/notes.
abstract interface class AnalyticsService {
  /// The app was brought to the foreground / launched.
  Future<void> logAppOpened();

  /// The user finished onboarding (name collected + profile marked
  /// complete), by any path.
  Future<void> logOnboardingCompleted();

  /// A blood-pressure reading was added to BP History by explicit user
  /// action. [imported] distinguishes a scanned/confirmed report reading
  /// from a manually typed one — no reading values are ever sent.
  Future<void> logBpReadingRecorded({required bool imported});

  /// A new reminder was created (not an edit of an existing one).
  Future<void> logReminderCreated();

  /// An educational article was opened. [articleId] is a stable content
  /// slug (e.g. `what-is-blood-pressure`) — not personal or health data.
  Future<void> logEducationalContentOpened({required String articleId});
}

/// Default implementation used when analytics isn't configured (e.g.
/// Firebase failed to initialize) and as the base for test fakes. Does
/// nothing, never throws.
final class NoOpAnalyticsService implements AnalyticsService {
  const NoOpAnalyticsService();

  @override
  Future<void> logAppOpened() async {}

  @override
  Future<void> logOnboardingCompleted() async {}

  @override
  Future<void> logBpReadingRecorded({required bool imported}) async {}

  @override
  Future<void> logReminderCreated() async {}

  @override
  Future<void> logEducationalContentOpened({required String articleId}) async {}
}
