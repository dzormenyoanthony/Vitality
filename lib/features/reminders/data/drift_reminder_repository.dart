import 'package:drift/drift.dart';

import '../../blood_pressure/data/app_database.dart';
import 'reminder.dart';
import 'reminder_repository.dart';

class DriftReminderRepository implements ReminderRepository {
  DriftReminderRepository(this._db);

  final AppDatabase _db;

  Set<int> _parseDays(String csv) =>
      csv.isEmpty ? <int>{} : csv.split(',').map(int.parse).toSet();

  String _formatDays(Set<int> days) => (days.toList()..sort()).join(',');

  Reminder _toDomain(ReminderRow row) {
    return Reminder(
      id: row.id,
      label: row.label,
      hour: row.hour,
      minute: row.minute,
      daysOfWeek: _parseDays(row.daysOfWeek),
      enabled: row.enabled,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  @override
  Stream<List<Reminder>> watchAll() {
    final query = _db.select(_db.reminders)
      ..orderBy([(r) => OrderingTerm.asc(r.hour), (r) => OrderingTerm.asc(r.minute)]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Stream<Reminder?> watchById(int id) {
    final query = _db.select(_db.reminders)..where((r) => r.id.equals(id));
    return query.watchSingleOrNull().map((row) => row == null ? null : _toDomain(row));
  }

  @override
  Future<List<Reminder>> getAll() async {
    final rows = await _db.select(_db.reminders).get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<int> addReminder({
    required String label,
    required int hour,
    required int minute,
    required Set<int> daysOfWeek,
    required bool enabled,
  }) {
    final now = DateTime.now();
    return _db
        .into(_db.reminders)
        .insert(
          RemindersCompanion.insert(
            label: label,
            hour: hour,
            minute: minute,
            daysOfWeek: _formatDays(daysOfWeek),
            enabled: Value(enabled),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  @override
  Future<void> updateReminder({
    required int id,
    required String label,
    required int hour,
    required int minute,
    required Set<int> daysOfWeek,
  }) {
    return (_db.update(_db.reminders)..where((r) => r.id.equals(id))).write(
      RemindersCompanion(
        label: Value(label),
        hour: Value(hour),
        minute: Value(minute),
        daysOfWeek: Value(_formatDays(daysOfWeek)),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> setEnabled(int id, bool enabled) {
    return (_db.update(_db.reminders)..where((r) => r.id.equals(id))).write(
      RemindersCompanion(enabled: Value(enabled), updatedAt: Value(DateTime.now())),
    );
  }

  @override
  Future<void> deleteReminder(int id) {
    return (_db.delete(_db.reminders)..where((r) => r.id.equals(id))).go();
  }

  @override
  Future<void> deleteAll() {
    return _db.delete(_db.reminders).go();
  }
}
