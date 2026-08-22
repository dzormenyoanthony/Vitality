import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/data/auth_providers.dart';
import '../../blood_pressure/data/blood_pressure_providers.dart';
import '../../onboarding/data/user_profile_providers.dart';
import '../../reminders/data/reminder_providers.dart';

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

  /// Deletes the account and every piece of data tied to it. Local storage
  /// isn't partitioned per user, so this also wipes local readings and
  /// reminders (PROJECT_SPEC.md §25) — otherwise they'd be stranded on the
  /// device with no owning account. The Firebase Auth user is deleted last:
  /// if an earlier step fails, the account is still intact and the user can
  /// retry, rather than being left signed-out with a half-deleted account.
  Future<void> deleteAccount(String uid) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final scheduler = ref.read(notificationSchedulerProvider);
      final reminderRepository = ref.read(reminderRepositoryProvider);
      final reminders = await reminderRepository.getAll();
      for (final reminder in reminders) {
        await scheduler.cancelReminder(reminder.id);
      }
      await reminderRepository.deleteAll();
      await ref.read(bloodPressureRepositoryProvider).deleteAll();
      await ref.read(userProfileRepositoryProvider).deleteProfile(uid);
      await ref.read(authRepositoryProvider).deleteAccount();
    });
  }
}

final settingsControllerProvider = AsyncNotifierProvider<SettingsController, void>(
  SettingsController.new,
);
