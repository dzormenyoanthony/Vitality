/// A candidate blood-pressure reading detected by OCR on a scanned/imported
/// report (PROJECT_SPEC.md "Scan BP Report" §4-5, §14).
///
/// This is UNCONFIRMED data. [needsReview] is always `true` until the user
/// explicitly confirms it — ML Kit's text recognizer exposes no per-value
/// confidence score, so per spec §14 ("if confidence information is
/// unavailable, treat all extracted health values as unconfirmed by
/// default") every extracted value is treated as needing review, not just
/// low-confidence ones.
final class ExtractedReading {
  const ExtractedReading({
    required this.id,
    required this.systolic,
    required this.diastolic,
    this.pulse,
    this.timestamp,
    this.needsReview = true,
  });

  /// Stable id for this candidate within its report — used for list keys
  /// and edit/delete targeting on the review screen, not persisted
  /// elsewhere.
  final int id;
  final int systolic;
  final int diastolic;
  final int? pulse;

  /// When the reading was taken, if a date/time was found nearby in the
  /// report. `null` means the user must supply it before confirming.
  final DateTime? timestamp;
  final bool needsReview;

  ExtractedReading copyWith({
    int? systolic,
    int? diastolic,
    int? Function()? pulse,
    DateTime? Function()? timestamp,
    bool? needsReview,
  }) {
    return ExtractedReading(
      id: id,
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      pulse: pulse != null ? pulse() : this.pulse,
      timestamp: timestamp != null ? timestamp() : this.timestamp,
      needsReview: needsReview ?? this.needsReview,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'systolic': systolic,
    'diastolic': diastolic,
    'pulse': pulse,
    'timestamp': timestamp?.toIso8601String(),
    'needsReview': needsReview,
  };

  factory ExtractedReading.fromJson(Map<String, dynamic> json) {
    return ExtractedReading(
      id: json['id'] as int,
      systolic: json['systolic'] as int,
      diastolic: json['diastolic'] as int,
      pulse: json['pulse'] as int?,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      needsReview: json['needsReview'] as bool? ?? true,
    );
  }
}
