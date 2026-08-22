import 'reminder.dart';

/// Abstraction over local reminder storage (Drift). Mirrors
/// [BloodPressureRepository]'s shape (`lib/features/blood_pressure/data/blood_pressure_repository.dart`).
abstract interface class ReminderRepository {
  Stream<List<Reminder>> watchAll();

  Stream<Reminder?> watchById(int id);

  Future<int> addReminder({
    required String label,
    required int hour,
    required int minute,
    required Set<int> daysOfWeek,
    required bool enabled,
  });

  Future<void> updateReminder({
    required int id,
    required String label,
    required int hour,
    required int minute,
    required Set<int> daysOfWeek,
  });

  Future<void> setEnabled(int id, bool enabled);

  Future<void> deleteReminder(int id);
}
