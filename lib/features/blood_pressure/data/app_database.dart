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

  /// Deprecated single-value column, kept only so v3 data survives the
  /// migration to [measurementContexts] below — no longer written to.
  TextColumn get measurementContext => text().nullable()();

  /// Comma-separated [MeasurementContext] names — same lightweight
  /// approach as [Reminders.daysOfWeek] rather than a join table, since
  /// this is just a small set of tags.
  TextColumn get measurementContexts => text().nullable()();
  TextColumn get bodyPosition => text().nullable()();
  TextColumn get cuffArm => text().nullable()();

  /// [ReadingSource] name — 'manual' (default) or 'importedReport'
  /// (PROJECT_SPEC.md §12, §33).
  TextColumn get source =>
      text().withDefault(const Constant('manual'))();

  /// The originating [SavedReports.id], set only when [source] is
  /// 'importedReport'.
  IntColumn get sourceReportId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  /// The Firestore document id once this row has been synced
  /// (PROJECT_SPEC.md §21-22) — `null` until the first successful push.
  TextColumn get remoteId => text().nullable()();

  /// Soft-delete marker: set instead of a hard SQL delete so the sync
  /// layer can propagate the deletion to Firestore before the local row
  /// is actually removed. Rows with this set are filtered out of every
  /// read query.
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

/// Local Drift table backing saved BP reports (PROJECT_SPEC.md
/// "Scan BP Report" §9). `extractedReadingsJson`/`confirmedReadingsJson`
/// hold JSON-encoded `List<ExtractedReading>` — each entry is itself a
/// small record, so JSON is a better fit here than the comma-separated
/// approach used for simpler columns like [Readings.measurementContexts].
@DataClassName('SavedReportRow')
class SavedReports extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();

  /// 'image' or 'pdf'.
  TextColumn get documentType => text()();
  DateTimeColumn get reportDate => dateTime().nullable()();
  IntColumn get pageCount => integer()();

  /// [OcrStatus] name.
  TextColumn get ocrStatus => text()();
  TextColumn get extractedReadingsJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get confirmedReadingsJson =>
      text().withDefault(const Constant('[]'))();

  /// 'scan' or 'import'.
  TextColumn get source => text()();

  /// Comma-separated local file paths for each page, in order.
  TextColumn get localPagePaths => text()();

  /// Comma-separated Firebase Storage paths, once uploaded — `null` until
  /// the first successful push, same pattern as [Readings.remoteId].
  TextColumn get storagePagePaths => text().nullable()();

  /// [ReportCategory] name — defaults to 'bpReport' so rows saved before
  /// this column existed keep their original meaning after migration.
  TextColumn get category =>
      text().withDefault(const Constant('bpReport'))();

  /// Optional free-text clinician/lab name.
  TextColumn get provider => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  /// The Firestore document id once this row's metadata has been synced.
  TextColumn get remoteId => text().nullable()();

  /// Soft-delete marker, same purpose as [Readings.deletedAt].
  DateTimeColumn get deletedAt => dateTime().nullable()();
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

  /// Optional silence window (minutes since midnight, 0-1439). When a
  /// reminder's fixed fire time falls inside this window, it's delivered
  /// silently (no sound/vibration) instead of not firing at all.
  IntColumn get quietHoursStartMinutes => integer().nullable()();
  IntColumn get quietHoursEndMinutes => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  /// The Firestore document id once this row has been synced
  /// (PROJECT_SPEC.md §21-22) — `null` until the first successful push.
  TextColumn get remoteId => text().nullable()();

  /// Soft-delete marker: set instead of a hard SQL delete so the sync
  /// layer can propagate the deletion to Firestore before the local row
  /// is actually removed. Rows with this set are filtered out of every
  /// read query.
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

@DriftDatabase(tables: [Readings, Reminders, SavedReports])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(reminders);
      }
      if (from < 3) {
        await m.addColumn(readings, readings.remoteId);
        await m.addColumn(readings, readings.deletedAt);
        await m.addColumn(reminders, reminders.remoteId);
        await m.addColumn(reminders, reminders.deletedAt);
      }
      if (from < 4) {
        await m.addColumn(readings, readings.measurementContexts);
        await m.addColumn(readings, readings.bodyPosition);
        await m.addColumn(readings, readings.cuffArm);
        await m.addColumn(reminders, reminders.quietHoursStartMinutes);
        await m.addColumn(reminders, reminders.quietHoursEndMinutes);
        // Carry the old single-value column forward into the new
        // multi-value one so v3 data isn't silently dropped.
        await m.database
            .customStatement(
              'UPDATE readings SET measurement_contexts = measurement_context '
              'WHERE measurement_context IS NOT NULL',
            );
      }
      if (from < 5) {
        await m.addColumn(readings, readings.source);
        await m.addColumn(readings, readings.sourceReportId);
        await m.createTable(savedReports);
      }
      if (from < 6) {
        await m.addColumn(savedReports, savedReports.category);
        await m.addColumn(savedReports, savedReports.provider);
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
