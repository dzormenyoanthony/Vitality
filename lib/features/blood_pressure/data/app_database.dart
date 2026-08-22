import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Local Drift table backing [BloodPressureReading]s (PROJECT_SPEC.md §5).
///
/// `measurementContext` is stored as the enum's name (nullable text) rather
/// than a Drift-generated converter, to keep the table definition simple —
/// conversion happens in [DriftBloodPressureRepository].
class Readings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get systolic => integer()();
  IntColumn get diastolic => integer()();
  IntColumn get pulse => integer().nullable()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get notes => text().nullable()();
  TextColumn get measurementContext => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

/// Local Drift table backing reminders (PROJECT_SPEC.md §17).
///
/// `daysOfWeek` is a comma-separated list of `DateTime.weekday` values
/// (1=Monday..7=Sunday), parsed in [DriftReminderRepository] — same
/// lightweight approach as `measurementContext` above rather than a
/// dedicated converter for what's just a small set of ints.
///
/// Named `ReminderRow` (via [DataClassName]) rather than the
/// auto-singularized `Reminder`, which would collide with the domain
/// model of that name in `lib/features/reminders/data/reminder.dart`.
@DataClassName('ReminderRow')
class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get label => text()();
  IntColumn get hour => integer()();
  IntColumn get minute => integer()();
  TextColumn get daysOfWeek => text()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

@DriftDatabase(tables: [Readings, Reminders])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(reminders);
      }
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'vitaly',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}
