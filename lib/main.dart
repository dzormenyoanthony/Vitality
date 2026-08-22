import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import 'core/constants/app_routes.dart';
import 'core/router/app_router.dart';
import 'core/router/auth_gate_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_provider.dart';
import 'core/utils/logger.dart';
import 'core/widgets/error_view.dart';
import 'features/reminders/data/flutter_local_notifications_scheduler.dart';
import 'features/reminders/data/reminder_deep_link_provider.dart';
import 'features/reminders/data/reminder_providers.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz_data.initializeTimeZones();
  try {
    final timezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezone.identifier));
  } catch (error, stackTrace) {
    // Falls back to the `timezone` package's UTC default. Reminder times
    // would be off from local wall-clock time in that case, but this is
    // rare (only if the platform timezone lookup itself fails) and
    // shouldn't block the rest of the app from starting.
    AppLogger.error('Failed to resolve local timezone', error: error, stackTrace: stackTrace);
  }

  final notificationScheduler = FlutterLocalNotificationsScheduler(
    FlutterLocalNotificationsPlugin(),
  );
  await notificationScheduler.initialize();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(
      ProviderScope(
        overrides: [notificationSchedulerProvider.overrideWithValue(notificationScheduler)],
        child: const VitalyApp(),
      ),
    );
  } catch (error, stackTrace) {
    AppLogger.error('Failed to initialize Firebase', error: error, stackTrace: stackTrace);
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
      title: 'Vitaly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const Scaffold(
        body: ErrorView(
          message: "Vitaly couldn't start. Please try again shortly.",
        ),
      ),
    );
  }
}

class VitalyApp extends ConsumerWidget {
  const VitalyApp({super.key});

  void _consumeDeepLinkIfReady(WidgetRef ref, GoRouter router) {
    if (!ref.read(pendingDeepLinkProvider)) return;
    if (ref.read(authGateProvider) is! AuthGateReady) return;
    ref.read(pendingDeepLinkProvider.notifier).clear();
    router.push(AppRoutes.recordBp);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    ref.listen(pendingDeepLinkProvider, (_, _) => _consumeDeepLinkIfReady(ref, router));
    ref.listen(authGateProvider, (_, _) => _consumeDeepLinkIfReady(ref, router));

    return MaterialApp.router(
      title: 'Vitaly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
