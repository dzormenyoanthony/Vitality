// Cross-device / large-text-scale responsiveness audit (superwall_paywall.md's
// sibling task): pumps every major screen across a matrix of small/tall/
// short/large phone sizes and large accessibility text scales, and fails
// listing every combination that throws (almost always a `RenderFlex
// overflowed` assertion) so real bugs surface as concrete, reproducible
// test failures rather than a manual screen-by-screen sweep.
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vitality/core/paywall/paywall_providers.dart';
import 'package:vitality/core/services/shared_preferences_provider.dart';
import 'package:vitality/features/authentication/data/auth_providers.dart';
import 'package:vitality/features/authentication/data/fake_auth_repository.dart';
import 'package:vitality/features/authentication/presentation/forgot_password_screen.dart';
import 'package:vitality/features/authentication/presentation/sign_in_screen.dart';
import 'package:vitality/features/authentication/presentation/sign_up_screen.dart';
import 'package:vitality/features/blood_pressure/data/app_database.dart';
import 'package:vitality/features/blood_pressure/data/blood_pressure_providers.dart';
import 'package:vitality/features/blood_pressure/data/blood_pressure_reading.dart';
import 'package:vitality/features/blood_pressure/data/drift_blood_pressure_repository.dart';
import 'package:vitality/features/blood_pressure/presentation/history_screen.dart';
import 'package:vitality/features/blood_pressure/presentation/reading_detail_screen.dart';
import 'package:vitality/features/blood_pressure/presentation/record_bp_screen.dart';
import 'package:vitality/features/blood_pressure/presentation/trends_screen.dart';
import 'package:vitality/features/dashboard/presentation/dashboard_screen.dart';
import 'package:vitality/features/data_export/presentation/export_data_screen.dart';
import 'package:vitality/features/education/data/article_repository.dart';
import 'package:vitality/features/education/presentation/article_detail_screen.dart';
import 'package:vitality/features/education/presentation/education_screen.dart';
import 'package:vitality/features/onboarding/data/fake_user_profile_repository.dart';
import 'package:vitality/features/onboarding/data/user_profile_providers.dart';
import 'package:vitality/features/onboarding/presentation/onboarding_complete_profile_screen.dart';
import 'package:vitality/features/onboarding/presentation/onboarding_name_screen.dart';
import 'package:vitality/features/reminders/data/drift_reminder_repository.dart';
import 'package:vitality/features/reminders/data/fake_notification_scheduler.dart';
import 'package:vitality/features/reminders/data/reminder_providers.dart';
import 'package:vitality/features/reminders/presentation/reminder_form_screen.dart';
import 'package:vitality/features/reminders/presentation/reminders_screen.dart';
import 'package:vitality/features/reports/data/drift_saved_report_repository.dart';
import 'package:vitality/features/reports/data/report_providers.dart';
import 'package:vitality/features/reports/domain/extracted_reading.dart';
import 'package:vitality/features/reports/domain/saved_report.dart';
import 'package:vitality/features/reports/domain/text_recognition_service.dart';
import 'package:vitality/features/reports/presentation/report_viewer_screen.dart';
import 'package:vitality/features/reports/presentation/review_extracted_screen.dart';
import 'package:vitality/features/reports/presentation/saved_reports_screen.dart';
import 'package:vitality/features/settings/presentation/settings_screen.dart';

import 'support/fake_paywall_service.dart';
import 'support/overflow_matrix.dart';
import 'support/pump_app.dart';

class _FakeTextRecognitionService implements TextRecognitionService {
  _FakeTextRecognitionService(this.textByPath);
  final Map<String, String> textByPath;

  @override
  Future<String> recognizeText(String imagePath) async => textByPath[imagePath] ?? '';

  @override
  Future<void> dispose() async {}
}

Future<SharedPreferences> _mockPrefs() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance();
}

void main() {
  group('authentication screens', () {
    testWidgets('SignInScreen', (tester) async {
      final prefs = await _mockPrefs();
      await expectNoOverflowAcrossDevices(
        tester,
        () => ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(
            localizationsDelegates: localizationWrappers,
            supportedLocales: testSupportedLocales,
            home: SignInScreen(),
          ),
        ),
      );
    });

    testWidgets('SignUpScreen', (tester) async {
      await expectNoOverflowAcrossDevices(
        tester,
        () => ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          ],
          child: const MaterialApp(
            localizationsDelegates: localizationWrappers,
            supportedLocales: testSupportedLocales,
            home: SignUpScreen(),
          ),
        ),
      );
    });

    testWidgets('ForgotPasswordScreen', (tester) async {
      await expectNoOverflowAcrossDevices(
        tester,
        () => ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          ],
          child: const MaterialApp(
            localizationsDelegates: localizationWrappers,
            supportedLocales: testSupportedLocales,
            home: ForgotPasswordScreen(),
          ),
        ),
      );
    });

    testWidgets('OnboardingNameScreen (also OnboardingCompleteProfileScreen\'s body)', (
      tester,
    ) async {
      await expectNoOverflowAcrossDevices(
        tester,
        () => MaterialApp(
          localizationsDelegates: localizationWrappers,
          supportedLocales: testSupportedLocales,
          home: Scaffold(
            body: OnboardingNameScreen(onSubmit: (_) {}, isSubmitting: false),
          ),
        ),
      );
    });

    testWidgets('OnboardingCompleteProfileScreen', (tester) async {
      final authRepository = FakeAuthRepository();
      await authRepository.signUp(email: 'a@b.com', password: 'password123');
      await expectNoOverflowAcrossDevices(
        tester,
        () => ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(authRepository)],
          child: const MaterialApp(
            localizationsDelegates: localizationWrappers,
            supportedLocales: testSupportedLocales,
            home: OnboardingCompleteProfileScreen(),
          ),
        ),
      );
    });
  });

  group('dashboard / history / trends / education', () {
    testWidgets('DashboardScreen (empty state)', (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await expectNoOverflowAcrossDevices(
        tester,
        () => ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
            userProfileRepositoryProvider.overrideWithValue(
              FakeUserProfileRepository(),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: localizationWrappers,
            supportedLocales: testSupportedLocales,
            home: DashboardScreen(),
          ),
        ),
      );
      await db.close();
    });

    testWidgets('DashboardScreen (with a reading)', (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await DriftBloodPressureRepository(db).addReading(
        systolic: 187,
        diastolic: 88,
        pulse: 76,
        timestamp: DateTime.now(),
        notes: 'evening, after medication',
      );
      await expectNoOverflowAcrossDevices(
        tester,
        () => ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
            userProfileRepositoryProvider.overrideWithValue(
              FakeUserProfileRepository(),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: localizationWrappers,
            supportedLocales: testSupportedLocales,
            home: DashboardScreen(),
          ),
        ),
      );
      await db.close();
    });

    testWidgets('HistoryScreen (with a reading)', (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await DriftBloodPressureRepository(db).addReading(
        systolic: 128,
        diastolic: 82,
        pulse: 70,
        timestamp: DateTime(2026, 1, 1, 8, 30),
        notes: 'A fairly long note to check that wrapping behaves under large text scale',
      );
      await expectNoOverflowAcrossDevices(
        tester,
        () => ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: const MaterialApp(
            localizationsDelegates: localizationWrappers,
            supportedLocales: testSupportedLocales,
            home: HistoryScreen(),
          ),
        ),
      );
      await db.close();
    });

    testWidgets('TrendsScreen (with readings)', (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = DriftBloodPressureRepository(db);
      await repo.addReading(systolic: 120, diastolic: 80, timestamp: DateTime.now());
      await repo.addReading(
        systolic: 130,
        diastolic: 90,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      );
      await expectNoOverflowAcrossDevices(
        tester,
        () => ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: const MaterialApp(
            localizationsDelegates: localizationWrappers,
            supportedLocales: testSupportedLocales,
            home: TrendsScreen(),
          ),
        ),
      );
      await db.close();
    });

    testWidgets('EducationScreen', (tester) async {
      await expectNoOverflowAcrossDevices(
        tester,
        () => const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: localizationWrappers,
            supportedLocales: testSupportedLocales,
            home: EducationScreen(),
          ),
        ),
      );
    });

    testWidgets('ArticleDetailScreen', (tester) async {
      final article = ArticleRepository.all().first;
      await expectNoOverflowAcrossDevices(
        tester,
        () => ProviderScope(
          child: MaterialApp(
            localizationsDelegates: localizationWrappers,
            supportedLocales: testSupportedLocales,
            home: ArticleDetailScreen(articleId: article.id),
          ),
        ),
      );
    });
  });

  group('record / reading detail / reminders', () {
    testWidgets('RecordBpScreen', (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await expectNoOverflowAcrossDevices(
        tester,
        () => ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: const MaterialApp(
            localizationsDelegates: localizationWrappers,
            supportedLocales: testSupportedLocales,
            home: RecordBpScreen(),
          ),
        ),
      );
      await db.close();
    });

    testWidgets('ReadingDetailScreen', (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final id = await DriftBloodPressureRepository(db).addReading(
        systolic: 128,
        diastolic: 82,
        pulse: 68,
        timestamp: DateTime(2026, 1, 5, 7, 15),
        notes: 'A fairly long note about this particular reading and its context',
        measurementContexts: [MeasurementContext.morning],
      );
      await expectNoOverflowAcrossDevices(
        tester,
        () => ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: MaterialApp(
            localizationsDelegates: localizationWrappers,
            supportedLocales: testSupportedLocales,
            home: ReadingDetailScreen(readingId: id),
          ),
        ),
      );
      await db.close();
    });

    testWidgets('RemindersScreen (with a reminder)', (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await DriftReminderRepository(db).addReminder(
        label: 'Morning reading before breakfast',
        hour: 7,
        minute: 30,
        daysOfWeek: {1, 2, 3, 4, 5},
        enabled: true,
      );
      final scheduler = FakeNotificationScheduler();
      addTearDown(scheduler.dispose);
      await expectNoOverflowAcrossDevices(
        tester,
        () => ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            notificationSchedulerProvider.overrideWithValue(scheduler),
          ],
          child: const MaterialApp(
            localizationsDelegates: localizationWrappers,
            supportedLocales: testSupportedLocales,
            home: RemindersScreen(),
          ),
        ),
      );
      await db.close();
    });

    testWidgets('ReminderFormScreen', (tester) async {
      await expectNoOverflowAcrossDevices(
        tester,
        () => const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: localizationWrappers,
            supportedLocales: testSupportedLocales,
            home: ReminderFormScreen(),
          ),
        ),
      );
    });
  });

  group('reports / export / settings', () {
    testWidgets('SavedReportsScreen (with a report)', (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await DriftSavedReportRepository(db).add(
        title: 'A fairly long report title to check wrapping under large text scale',
        documentType: ReportDocumentType.image,
        reportDate: DateTime(2026, 8, 22),
        pageCount: 2,
        ocrStatus: OcrStatus.succeeded,
        confirmedReadings: const [
          ExtractedReading(id: 0, systolic: 136, diastolic: 84),
        ],
        source: ReportSource.scan,
        localPagePaths: ['/tmp/page_0.jpg', '/tmp/page_1.jpg'],
        category: ReportCategory.labResults,
        provider: 'Northside Laboratory and Diagnostic Center',
      );
      await expectNoOverflowAcrossDevices(
        tester,
        () => ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: const MaterialApp(
            localizationsDelegates: localizationWrappers,
            supportedLocales: testSupportedLocales,
            home: SavedReportsScreen(),
          ),
        ),
      );
      await db.close();
    });

    testWidgets('ReportViewerScreen (not found state)', (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await expectNoOverflowAcrossDevices(
        tester,
        () => ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: const MaterialApp(
            localizationsDelegates: localizationWrappers,
            supportedLocales: testSupportedLocales,
            home: ReportViewerScreen(reportId: 999),
          ),
        ),
      );
      await db.close();
    });

    testWidgets('ReviewExtractedScreen', (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final fakeOcr = _FakeTextRecognitionService({
        '/tmp/page_0.jpg': '136/84 mmHg\nPulse 72 bpm',
      });
      await expectNoOverflowAcrossDevices(
        tester,
        () => ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            textRecognitionServiceProvider.overrideWithValue(fakeOcr),
          ],
          child: const MaterialApp(
            localizationsDelegates: localizationWrappers,
            supportedLocales: testSupportedLocales,
            home: ReviewExtractedScreen(
              args: ReviewExtractedArgs(
                rawPagePaths: ['/tmp/page_0.jpg'],
                documentType: ReportDocumentType.image,
                source: ReportSource.scan,
              ),
            ),
          ),
        ),
      );
      await db.close();
    });

    testWidgets('ExportDataScreen (with readings)', (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = DriftBloodPressureRepository(db);
      await repo.addReading(systolic: 122, diastolic: 80, pulse: 70, timestamp: DateTime.now());
      await expectNoOverflowAcrossDevices(
        tester,
        () => ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            paywallServiceProvider.overrideWithValue(FakePaywallService()),
          ],
          child: const MaterialApp(
            localizationsDelegates: localizationWrappers,
            supportedLocales: testSupportedLocales,
            home: ExportDataScreen(),
          ),
        ),
      );
      await db.close();
    });

    testWidgets('SettingsScreen', (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final scheduler = FakeNotificationScheduler();
      addTearDown(scheduler.dispose);
      final authRepository = FakeAuthRepository();
      final profileRepository = FakeUserProfileRepository();
      addTearDown(profileRepository.dispose);
      final user = await authRepository.signUp(email: 'a@b.com', password: 'password123');
      await profileRepository.createProfile(
        uid: user.uid,
        displayName: 'A Fairly Long Preferred Display Name',
      );
      final prefs = await _mockPrefs();
      await expectNoOverflowAcrossDevices(
        tester,
        () => ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            notificationSchedulerProvider.overrideWithValue(scheduler),
            authRepositoryProvider.overrideWithValue(authRepository),
            userProfileRepositoryProvider.overrideWithValue(profileRepository),
            sharedPreferencesProvider.overrideWithValue(prefs),
            paywallServiceProvider.overrideWithValue(FakePaywallService()),
          ],
          child: const MaterialApp(
            localizationsDelegates: localizationWrappers,
            supportedLocales: testSupportedLocales,
            home: SettingsScreen(),
          ),
        ),
      );
      await db.close();
    });
  });
}
