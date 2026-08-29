import 'package:vitality/core/analytics/analytics_service.dart';

/// Records every analytics call as a short descriptor string so tests can
/// assert which §26 events fired, in order.
final class FakeAnalyticsService implements AnalyticsService {
  final List<String> events = [];

  @override
  Future<void> logAppOpened() async => events.add('app_opened');

  @override
  Future<void> logOnboardingCompleted() async =>
      events.add('onboarding_completed');

  @override
  Future<void> logBpReadingRecorded({required bool imported}) async =>
      events.add('bp_reading_recorded:imported=$imported');

  @override
  Future<void> logReminderCreated() async => events.add('reminder_created');

  @override
  Future<void> logEducationalContentOpened({required String articleId}) async =>
      events.add('educational_content_opened:$articleId');
}
