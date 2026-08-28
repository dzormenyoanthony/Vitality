/// Optional predefined context for a reading (PROJECT_SPEC.md §5). A reading
/// may carry more than one — e.g. both "Morning" and "Before medication".
enum MeasurementContext {
  morning,
  evening,
  beforeMedication,
  afterMedication,
  afterExercise,
  afterMeal,
  other,
}

/// Optional body position at time of measurement.
enum BodyPosition { sitting, standing, lying }

/// Optional arm the cuff was worn on.
enum CuffArm { left, right }

/// Where a reading came from (PROJECT_SPEC.md §12, §33). A reading entered
/// through Scan BP Report keeps this distinction permanently, even after
/// it's confirmed into BP History and classified like any other reading.
enum ReadingSource { manual, importedReport }

/// A single blood-pressure measurement (PROJECT_SPEC.md §5).
///
/// `id` is a local auto-increment integer for now — Phase 3 is local-only
/// storage; a stable cross-device identifier is only needed once Firestore
/// sync is introduced (Phase 6).
final class BloodPressureReading {
  const BloodPressureReading({
    required this.id,
    required this.systolic,
    required this.diastolic,
    this.pulse,
    required this.timestamp,
    this.notes,
    this.measurementContexts = const [],
    this.bodyPosition,
    this.cuffArm,
    this.source = ReadingSource.manual,
    this.sourceReportId,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;

  /// Systolic pressure in mmHg.
  final int systolic;

  /// Diastolic pressure in mmHg.
  final int diastolic;

  /// Heart rate in bpm, if recorded.
  final int? pulse;

  /// When the measurement was taken.
  final DateTime timestamp;

  /// Optional free-text notes (e.g. "felt stressed").
  final String? notes;

  final List<MeasurementContext> measurementContexts;
  final BodyPosition? bodyPosition;
  final CuffArm? cuffArm;

  /// Where this reading came from. Defaults to [ReadingSource.manual].
  final ReadingSource source;

  /// The [SavedReport.id] this reading was confirmed from, when
  /// [source] is [ReadingSource.importedReport].
  final int? sourceReportId;
  final DateTime createdAt;
  final DateTime updatedAt;
}
