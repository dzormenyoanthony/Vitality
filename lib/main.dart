import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import 'l10n/app_localizations.dart';

import 'core/analytics/analytics_providers.dart';
import 'core/analytics/firebase_analytics_service.dart';
import 'core/config/superwall_config.dart';
import 'core/constants/app_routes.dart';
import 'core/paywall/paywall_providers.dart';
import 'core/paywall/paywall_service.dart';
import 'core/paywall/superwall_paywall_service.dart';
import 'core/router/app_router.dart';
import 'core/router/auth_gate_provider.dart';
import 'core/services/shared_preferences_provider.dart';
import 'core/sync/sync_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_provider.dart';
import 'core/utils/logger.dart';
import 'core/widgets/error_view.dart';
import 'features/authentication/data/keep_signed_in_provider.dart';
import 'features/onboarding/data/onboarding_intro_provider.dart';
import 'features/blood_pressure/data/app_database.dart';
import 'features/blood_pressure/data/blood_pressure_providers.dart';
import 'features/blood_pressure/data/drift_blood_pressure_repository.dart';
import 'features/reminders/data/drift_reminder_repository.dart';
import 'features/reminders/data/flutter_local_notifications_scheduler.dart';
import 'features/reminders/data/reminder_deep_link_provider.dart';
import 'features/reminders/data/reminder_providers.dart';
import 'features/reports/data/drift_saved_report_repository.dart';
import 'features/reports/data/report_document_storage.dart';
import 'features/reports/data/report_providers.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Android 15 (API 35) enforces edge-to-edge and deprecates the window
  // colour setters the engine would otherwise use. Opt in explicitly via
  // the current API so the layout is consistent on older versions too;
  // the transparent system bars let content draw underneath, and every
  // screen already insets its content with SafeArea.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  tz_data.initializeTimeZones();
  try {
    final timezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezone.identifier));
  } catch (error, stackTrace) {
    // Falls back to the `timezone` package's UTC default. Reminder times
    // would be off from local wall-clock time in that case, but this is
    // rare (only if the platform timezone lookup itself fails) and
    // shouldn't block the rest of the app from starting.
    AppLogger.error(
      'Failed to resolve local timezone',
      error: error,
      stackTrace: stackTrace,
    );
  }

  final notificationScheduler = FlutterLocalNotificationsScheduler(
    FlutterLocalNotificationsPlugin(),
  );
  await notificationScheduler.initialize();

  final sharedPreferences = await SharedPreferences.getInstance();
  final db = AppDatabase();
  String? currentUid() => fb.FirebaseAuth.instance.currentUser?.uid;

  // Superwall gates the premium actions listed in PROJECT_SPEC.md §27; see
  // core/paywall/. Falls back to NoOpPaywallService (paywallServiceProvider's
  // default, left un-overridden) when no API key was supplied at build
  // time, so a dev/CI build without the dashboard set up still runs rather
  // than crashing on a blank key.
  PaywallService? paywallService;
  if (SuperwallConfig.isConfigured) {
    try {
      Superwall.configure(SuperwallConfig.apiKey);
      paywallService = const SuperwallPaywallService();
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to configure Superwall',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Firebase Auth persists a session across app restarts by itself; if
    // the user unchecked "Keep me signed in" on the Sign In screen, undo
    // that restored session here, before the router ever sees it.
    final keepSignedIn =
        sharedPreferences.getBool(keepSignedInPrefsKey) ?? true;
    if (!keepSignedIn) {
      await fb.FirebaseAuth.instance.signOut();
    }
    runApp(
      ProviderScope(
        overrides: [
          notificationSchedulerProvider.overrideWithValue(
            notificationScheduler,
          ),
          analyticsServiceProvider.overrideWithValue(
            FirebaseAnalyticsService(FirebaseAnalytics.instance),
          ),
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          appDatabaseProvider.overrideWithValue(db),
          bloodPressureRepositoryProvider.overrideWithValue(
            DriftBloodPressureRepository(
              db,
              firestore: FirebaseFirestore.instance,
              currentUid: currentUid,
            ),
          ),
          reminderRepositoryProvider.overrideWithValue(
            DriftReminderRepository(
              db,
              firestore: FirebaseFirestore.instance,
              currentUid: currentUid,
            ),
          ),
          savedReportRepositoryProvider.overrideWithValue(
            DriftSavedReportRepository(
              db,
              firestore: FirebaseFirestore.instance,
              currentUid: currentUid,
            ),
          ),
          reportDocumentStorageProvider.overrideWithValue(
            ReportDocumentStorage(
              storage: FirebaseStorage.instance,
              currentUid: currentUid,
            ),
          ),
          if (paywallService != null)
            paywallServiceProvider.overrideWithValue(paywallService),
        ],
        child: const VitalyApp(),
      ),
    );
  } catch (error, stackTrace) {
    AppLogger.error(
      'Failed to initialize Firebase',
      error: error,
      stackTrace: stackTrace,
    );
    runApp(const _StartupFailureApp());
  }
}

/// Shown if Firebase fails to initialize (e.g. missing platform config)
/// instead of crashing with a raw exception (CLAUDE.md §12).
class _StartupFailureApp extends StatelessWidget {
  const _StartupFailureApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: ErrorView(
            message: AppLocalizations.of(context).startupFailureMessage,
          ),
        ),
      ),
    );
  }
}

class VitalyApp extends ConsumerStatefulWidget {
  const VitalyApp({super.key});

  @override
  ConsumerState<VitalyApp> createState() => _VitalyAppState();
}

class _VitalyAppState extends ConsumerState<VitalyApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // PROJECT_SPEC.md §26 "app opened". Also fired on each resume below.
    ref.read(analyticsServiceProvider).logAppOpened();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// The "connection restored" half of PROJECT_SPEC.md §22's sync flow: no
  /// live connectivity listener, just a resync whenever the user returns
  /// to the app — a simple, honest proxy that needs no extra dependency.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    ref.read(analyticsServiceProvider).logAppOpened();
    final gate = ref.read(authGateProvider);
    if (gate is AuthGateReady) {
      ref.read(syncCoordinatorProvider).syncAll(gate.uid);
    }
  }

  void _consumeDeepLinkIfReady(WidgetRef ref, GoRouter router) {
    if (!ref.read(pendingDeepLinkProvider)) return;
    if (ref.read(authGateProvider) is! AuthGateReady) return;
    ref.read(pendingDeepLinkProvider.notifier).clear();
    router.push(AppRoutes.recordBp);
  }

  /// Kicks off a sync pass on every sign-in (including a fresh device
  /// downloading existing history for the first time), and clears local
  /// data on sign-out so a different account signing in on the same
  /// device never sees the previous account's cached rows
  /// (PROJECT_SPEC.md §21-22).
  void _handleAuthGateChange(AuthGateState? previous, AuthGateState next) {
    if (next is AuthGateReady) {
      ref.read(syncCoordinatorProvider).syncAll(next.uid);
      // Once fully onboarded, this device should never show the intro
      // carousel again — a later sign-out must land on Sign In, not
      // Onboarding (PROJECT_SPEC.md §30).
      ref.read(onboardingIntroSeenProvider.notifier).markSeen();
      // Ties entitlement state to the signed-in account so a purchase made
      // on one device is recognized after signing in on another, and
      // survives this app restarting while the subscription is active.
      ref.read(paywallServiceProvider).identify(next.uid);
    } else if (next is AuthGateUnauthenticated) {
      ref.read(bloodPressureRepositoryProvider).deleteAll();
      ref.read(reminderRepositoryProvider).deleteAll();
      ref.read(savedReportRepositoryProvider).deleteAll();
      // Clears the previous account's identified user so a different
      // account signing in on the same device doesn't inherit its cached
      // entitlement state.
      ref.read(paywallServiceProvider).reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    ref.listen(
      pendingDeepLinkProvider,
      (_, _) => _consumeDeepLinkIfReady(ref, router),
    );
    ref.listen(
      authGateProvider,
      (_, _) => _consumeDeepLinkIfReady(ref, router),
    );
    ref.listen(authGateProvider, _handleAuthGateChange);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
