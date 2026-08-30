import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vitality/core/services/shared_preferences_provider.dart';
import 'package:vitality/core/sync/sync_coordinator.dart';
import 'package:vitality/core/sync/sync_provider.dart';
import 'package:vitality/features/authentication/data/auth_providers.dart';
import 'package:vitality/features/authentication/data/fake_auth_repository.dart';
import 'package:vitality/features/blood_pressure/data/app_database.dart';
import 'package:vitality/features/blood_pressure/data/blood_pressure_providers.dart';
import 'package:vitality/features/blood_pressure/data/drift_blood_pressure_repository.dart';
import 'package:vitality/features/onboarding/data/fake_user_profile_repository.dart';
import 'package:vitality/features/onboarding/data/user_profile_providers.dart';
import 'package:vitality/features/reminders/data/fake_notification_scheduler.dart';
import 'package:vitality/features/reminders/data/reminder_providers.dart';
import 'package:vitality/main.dart';

/// PROJECT_SPEC.md §37: end-to-end coverage of the §22 offline-save-then-sync
/// flow, driving the real app (routing, screens, Drift streams) against a
/// controllable Firestore.
///
/// "Offline" is modelled by wiring the reading repository *without* a
/// Firestore handle — its best-effort push is a no-op, exactly as it is
/// when the network write fails — while the `SyncCoordinator` (the
/// reconnect / catch-up pass) stays wired to the fake. "Online" wires the
/// repository to the fake so its push lands immediately. Both share one
/// in-memory Drift database.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<_Harness> boot(
    WidgetTester tester, {
    required bool repoOnline,
    void Function(FakeFirebaseFirestore firestore, String uid)? seedRemote,
  }) async {
    final auth = FakeAuthRepository();
    final profiles = FakeUserProfileRepository();
    final scheduler = FakeNotificationScheduler();
    final db = AppDatabase(NativeDatabase.memory());
    final firestore = FakeFirebaseFirestore();

    final user = await auth.signUp(
      email: 'sync@example.com',
      password: 'password123',
    );
    await profiles.createProfile(uid: user.uid, displayName: 'Sam');
    await profiles.completeOnboarding(user.uid);
    seedRemote?.call(firestore, user.uid);

    SharedPreferences.setMockInitialValues({'onboarding_intro_seen': true});
    final prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        userProfileRepositoryProvider.overrideWithValue(profiles),
        notificationSchedulerProvider.overrideWithValue(scheduler),
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(db),
        bloodPressureRepositoryProvider.overrideWithValue(
          DriftBloodPressureRepository(
            db,
            firestore: repoOnline ? firestore : null,
            currentUid: repoOnline ? () => user.uid : null,
          ),
        ),
        syncCoordinatorProvider.overrideWithValue(
          SyncCoordinator(db, firestore),
        ),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(db.close);
    addTearDown(auth.dispose);
    addTearDown(profiles.dispose);
    addTearDown(scheduler.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const VitalyApp(),
      ),
    );
    // Clear the 2s branded-splash floor, then let the auth gate resolve and
    // the app settle onto the Dashboard.
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 500));

    return _Harness(container, firestore, user.uid);
  }

  Future<void> recordReading(
    WidgetTester tester, {
    required String systolic,
    required String diastolic,
  }) async {
    await tester.tap(find.text('Add reading'));
    await _settle(tester);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Systolic (mmHg)'),
      systolic,
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Diastolic (mmHg)'),
      diastolic,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save reading'));
    await _settle(tester);
  }

  testWidgets(
    'offline: a reading saves locally and syncs up once the connection is restored',
    (tester) async {
      final h = await boot(tester, repoOnline: false);

      await recordReading(tester, systolic: '128', diastolic: '82');

      // Saved locally — the Dashboard latest-reading card shows it.
      expect(find.text('128'), findsWidgets);
      expect(find.text('82'), findsWidgets);

      // Nothing pushed while offline.
      expect((await _remoteReadings(h)).docs, isEmpty);

      // Connection restored → the catch-up sync pushes the backlog.
      await h.container.read(syncCoordinatorProvider).syncAll(h.uid);

      final remote = await _remoteReadings(h);
      expect(remote.docs, hasLength(1));
      expect(remote.docs.single.data()['systolic'], 128);
      expect(remote.docs.single.data()['diastolic'], 82);
    },
  );

  testWidgets(
    'a remote-only reading is pulled into local History after a sync',
    (tester) async {
      final seededAt = DateTime(2026, 8, 20, 9);
      final h = await boot(
        tester,
        repoOnline: false,
        seedRemote: (firestore, uid) {
          firestore
              .collection('users')
              .doc(uid)
              .collection('readings')
              .add({
                'systolic': 145,
                'diastolic': 95,
                'timestamp': Timestamp.fromDate(seededAt),
                'source': 'manual',
                'createdAt': Timestamp.fromDate(seededAt),
                'updatedAt': Timestamp.fromDate(seededAt),
              });
        },
      );

      // The app auto-syncs on reaching the signed-in state; run it again so
      // the assertion doesn't race that.
      await h.container.read(syncCoordinatorProvider).syncAll(h.uid);
      await _settle(tester);

      await tester.tap(find.text('History'));
      await _settle(tester);

      await _pumpUntil(tester, find.text('145/95'));
    },
  );

  testWidgets(
    'online: a saved reading reaches Firestore without an explicit sync',
    (tester) async {
      final h = await boot(tester, repoOnline: true);

      await recordReading(tester, systolic: '120', diastolic: '78');

      // The repository's best-effort push is fire-and-forget; give it a
      // moment to land, then confirm.
      await _expectRemoteCount(h, 1);
      final remote = await _remoteReadings(h);
      expect(remote.docs.single.data()['systolic'], 120);
      expect(remote.docs.single.data()['diastolic'], 78);
    },
  );
}

class _Harness {
  _Harness(this.container, this.firestore, this.uid);

  final ProviderContainer container;
  final FakeFirebaseFirestore firestore;
  final String uid;
}

Future<QuerySnapshot<Map<String, dynamic>>> _remoteReadings(_Harness h) => h
    .firestore
    .collection('users')
    .doc(h.uid)
    .collection('readings')
    .get();

/// A bounded alternative to `pumpAndSettle()` — a focused field's cursor
/// timer reschedules frames forever, so unfocus first, then pump a fixed
/// span that covers the default page transition.
Future<void> _settle(WidgetTester tester) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 700));
}

Future<void> _pumpUntil(
  WidgetTester tester,
  Finder finder, {
  int tries = 50,
}) async {
  for (var i = 0; i < tries; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  expect(finder, findsWidgets);
}

Future<void> _expectRemoteCount(_Harness h, int count, {int tries = 60}) async {
  for (var i = 0; i < tries; i++) {
    if ((await _remoteReadings(h)).docs.length == count) return;
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
  expect((await _remoteReadings(h)).docs, hasLength(count));
}
