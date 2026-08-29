import 'package:firebase_analytics/firebase_analytics.dart';

import '../utils/logger.dart';
import 'analytics_service.dart';

/// [AnalyticsService] backed by Firebase Analytics (PROJECT_SPEC.md §26).
///
/// Every call is wrapped so an analytics failure can never surface to the
/// user or break a flow — a dropped event is logged and forgotten.
/// Event names are our own snake_case slugs, kept distinct from Firebase's
/// automatically collected events (e.g. our `app_opened` vs. the SDK's
/// `app_open`).
final class FirebaseAnalyticsService implements AnalyticsService {
  const FirebaseAnalyticsService(this._analytics);

  final FirebaseAnalytics _analytics;

  Future<void> _log(String name, [Map<String, Object>? parameters]) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (error, stackTrace) {
      AppLogger.error(
        'Analytics event "$name" was dropped',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> logAppOpened() => _log('app_opened');

  @override
  Future<void> logOnboardingCompleted() => _log('onboarding_completed');

  @override
  Future<void> logBpReadingRecorded({required bool imported}) => _log(
    'bp_reading_recorded',
    {'source': imported ? 'imported_report' : 'manual'},
  );

  @override
  Future<void> logReminderCreated() => _log('reminder_created');

  @override
  Future<void> logEducationalContentOpened({required String articleId}) =>
      _log('educational_content_opened', {'article_id': articleId});
}
