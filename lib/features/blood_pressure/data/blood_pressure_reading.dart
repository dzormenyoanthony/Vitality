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
  final DateTime createdAt;
  final DateTime updatedAt;
}
