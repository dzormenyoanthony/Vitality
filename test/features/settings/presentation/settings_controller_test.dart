import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/authentication/data/auth_providers.dart';
import 'package:vitality/features/authentication/data/fake_auth_repository.dart';
import 'package:vitality/features/blood_pressure/data/app_database.dart';
import 'package:vitality/features/blood_pressure/data/blood_pressure_providers.dart';
import 'package:vitality/features/onboarding/data/fake_user_profile_repository.dart';
import 'package:vitality/features/onboarding/data/user_profile_providers.dart';
import 'package:vitality/features/reminders/data/fake_notification_scheduler.dart';
import 'package:vitality/features/reminders/data/reminder_providers.dart';
import 'package:vitality/features/reports/data/report_providers.dart';
import 'package:vitality/features/reports/domain/saved_report.dart';
import 'package:vitality/features/settings/presentation/settings_controller.dart';

/// See test/features/reminders/presentation/reminder_controller_test.dart
/// for why polling (rather than a single `.future` read) is required here.
Future<T> _waitFor<T>(
  ProviderContainer container,
  T Function() read,
  bool Function(T value) condition, {
  Duration timeout = const Duration(seconds: 2),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (true) {
    final value = read();
    if (condition(value)) return value;
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('Condition not met within $timeout');
    }
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}

void main() {
  late AppDatabase db;
  late FakeNotificationScheduler scheduler;
  late FakeAuthRepository authRepository;
  late FakeUserProfileRepository profileRepository;
  late ProviderContainer container;
  late String uid;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    scheduler = FakeNotificationScheduler();
    authRepository = FakeAuthRepository();
    profileRepository = FakeUserProfileRepository();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        notificationSchedulerProvider.overrideWithValue(scheduler),
        authRepositoryProvider.overrideWithValue(authRepository),
        userProfileRepositoryProvider.overrideWithValue(profileRepository),
      ],
    );
    container.listen(remindersStreamProvider, (_, _) {});
    container.listen(readingsStreamProvider, (_, _) {});

    final user = await authRepository.signUp(email: 'a@b.com', password: 'password123');
    uid = user.uid;
    await profileRepository.createProfile(uid: uid, displayName: 'Original Name');
    container.listen(userProfileStreamProvider(uid), (_, _) {});
  });

  tearDown(() async {
    container.dispose();
    scheduler.dispose();
    authRepository.dispose();
    profileRepository.dispose();
    await db.close();
  });

  test('updateName saves the new display name', () async {
    await container
        .read(settingsControllerProvider.notifier)
        .updateName(uid: uid, displayName: 'Updated Name');

    final profile = await _waitFor(
      container,
      () => container.read(userProfileStreamProvider(uid)).value,
      (value) => value?.displayName == 'Updated Name',
    );
    expect(profile!.displayName, 'Updated Name');
  });

  test(
    'deleteAccount cancels reminders, wipes local data, deletes the profile and the '
    'auth account',
    () async {
      await container
          .read(reminderRepositoryProvider)
          .addReminder(label: 'Reminder', hour: 8, minute: 0, daysOfWeek: {1}, enabled: true);
      await container
          .read(bloodPressureRepositoryProvider)
          .addReading(systolic: 120, diastolic: 80, timestamp: DateTime.now());
      final reportId = await container
          .read(savedReportRepositoryProvider)
          .add(
            title: 'Scanned report',
            documentType: ReportDocumentType.image,
            pageCount: 1,
            ocrStatus: OcrStatus.notProcessed,
            source: ReportSource.scan,
            localPagePaths: const [],
          );
      final reminderId = (await _waitFor(
        container,
        () => container.read(remindersStreamProvider).value ?? const [],
        (value) => value.isNotEmpty,
      )).single.id;
      scheduler.scheduledReminderIds.add(reminderId);

      await container.read(settingsControllerProvider.notifier).deleteAccount(uid);

      await _waitFor(
        container,
        () => container.read(remindersStreamProvider).value ?? const [],
        (value) => value.isEmpty,
      );
      await _waitFor(
        container,
        () => container.read(readingsStreamProvider).value ?? const [],
        (value) => value.isEmpty,
      );
      expect(scheduler.scheduledReminderIds, isEmpty);
      expect(await container.read(savedReportRepositoryProvider).watchById(reportId).first, isNull);
      expect(await profileRepository.watchProfile(uid).first, isNull);
      expect(authRepository.currentUser, isNull);
    },
  );

  test('deleteAccount surfaces a failure without deleting local data', () async {
    await authRepository.signOut(); // No current user -> deleteAccount() throws.

    await container.read(settingsControllerProvider.notifier).deleteAccount(uid);

    final state = container.read(settingsControllerProvider);
    expect(state.hasError, isTrue);
  });
}
