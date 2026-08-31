import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/logger.dart';
import '../../authentication/data/auth_providers.dart';
import '../../blood_pressure/data/blood_pressure_providers.dart';
import '../../onboarding/data/user_profile_providers.dart';
import '../../reminders/data/reminder_providers.dart';
import '../../reports/data/report_providers.dart';

/// Handles profile edits and account deletion. Mirrors the shape of
/// [OnboardingController]/[ReminderController]: an [AsyncNotifier] that
/// only tracks the current action's loading/error state, wrapping
/// repository calls in [AsyncValue.guard].
class SettingsController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> updateName({required String uid, required String displayName}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(userProfileRepositoryProvider).updateDisplayName(uid, displayName);
    });
  }

  /// Deletes the account and every piece of data tied to it
  /// (PROJECT_SPEC.md §24, §25).
  ///
  /// Order matters. The account and its cloud profile are removed *before*
  /// any local data, so a failure can't leave readings/reminders stranded
  /// on the device under an account that's already gone — the previous
  /// order wiped everything first and then hit `requires-recent-login` on
  /// `user.delete()`, leaving the account alive but empty.
  ///
  /// 1. Re-verify identity. If this fails (a stale session that needs a
  ///    fresh sign-in, or the user backing out) nothing has been touched.
  /// 2. Delete the cloud profile while still authenticated, then the auth
  ///    user itself.
  /// 3. Wipe local, device-only data. Best-effort: the account is already
  ///    gone, so a failure here is logged, not surfaced as a retry.
  Future<void> deleteAccount(String uid) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final authRepository = ref.read(authRepositoryProvider);

      await authRepository.reauthenticate();

      await ref.read(userProfileRepositoryProvider).deleteProfile(uid);
      await authRepository.deleteAccount();

      try {
        final scheduler = ref.read(notificationSchedulerProvider);
        final reminderRepository = ref.read(reminderRepositoryProvider);
        final reminders = await reminderRepository.getAll();
        for (final reminder in reminders) {
          await scheduler.cancelReminder(reminder.id);
        }
        await reminderRepository.deleteAll();
        await ref.read(bloodPressureRepositoryProvider).deleteAll();

        final reportRepository = ref.read(savedReportRepositoryProvider);
        final reportStorage = ref.read(reportDocumentStorageProvider);
        final reports = await reportRepository.getAll();
        for (final report in reports) {
          await reportStorage.deleteLocalPages(report.localPagePaths);
        }
        await reportRepository.deleteAll();
      } catch (error, stackTrace) {
        AppLogger.error(
          'Local data wipe after account deletion did not fully complete',
          error: error,
          stackTrace: stackTrace,
        );
      }
    });
  }
}

final settingsControllerProvider = AsyncNotifierProvider<SettingsController, void>(
  SettingsController.new,
);
