import 'reminder.dart';

/// Abstraction over local reminder storage (Drift). Mirrors
/// [BloodPressureRepository]'s shape (`lib/features/blood_pressure/data/blood_pressure_repository.dart`).
abstract interface class ReminderRepository {
  Stream<List<Reminder>> watchAll();

  Stream<Reminder?> watchById(int id);

  /// A one-shot read, for callers that need a single snapshot rather than
  /// a live subscription (e.g. deleting an account).
  Future<List<Reminder>> getAll();

  Future<int> addReminder({
    required String label,
    required int hour,
    required int minute,
    required Set<int> daysOfWeek,
    required bool enabled,
    (int hour, int minute)? quietHoursStart,
    (int hour, int minute)? quietHoursEnd,
  });

  Future<void> updateReminder({
    required int id,
    required String label,
    required int hour,
    required int minute,
    required Set<int> daysOfWeek,
    (int hour, int minute)? quietHoursStart,
    (int hour, int minute)? quietHoursEnd,
  });

  Future<void> setEnabled(int id, bool enabled);

  Future<void> deleteReminder(int id);

  /// Deletes every reminder. Used when deleting the account (PROJECT_SPEC.md
  /// §25) — local storage isn't partitioned per user, so this is a full wipe.
  Future<void> deleteAll();
}
