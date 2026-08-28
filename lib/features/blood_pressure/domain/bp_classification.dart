/// A non-diagnostic status category for a recorded blood-pressure reading
/// or average (PROJECT_SPEC.md §18-21). This describes the RECORDED
/// VALUE, never the user's medical condition — see the approved wording in
/// [BPCategory.label] and §29's approved/avoid language lists.
///
/// Ordered by severity, lowest first — [index] doubles as the severity
/// rank used to pick "the higher applicable category" when systolic and
/// diastolic fall into different categories (§20).
enum BPCategory {
  normal,
  elevated,
  higher,
  high;

  /// The approved, non-diagnostic display label (PROJECT_SPEC.md §21, §29).
  String get label => switch (this) {
    BPCategory.normal => 'Looks good',
    BPCategory.elevated => 'Worth keeping an eye on',
    BPCategory.higher => 'Higher than the usual range',
    BPCategory.high => 'This reading is high',
  };
}

/// The result of classifying one systolic/diastolic pair
/// (PROJECT_SPEC.md §18). Carries the actual values and the reference
/// bounds that produced [category], so [explanation] can be generated from
/// this data rather than duplicated per screen (§24).
final class BPClassification {
  const BPClassification({
    required this.category,
    required this.systolic,
    required this.diastolic,
    required this.systolicRangeLabel,
    required this.diastolicRangeLabel,
  });

  final BPCategory category;
  final int systolic;
  final int diastolic;

  /// Human-readable systolic range that produced this classification, e.g.
  /// "130–139" or "≥140" — used by [explanation].
  final String systolicRangeLabel;

  /// Human-readable diastolic range that produced this classification, e.g.
  /// "80–89" or "<80".
  final String diastolicRangeLabel;

  /// Generates the "Why am I seeing this?" explanation from this
  /// classification's own data (PROJECT_SPEC.md §24) — never a diagnosis,
  /// always describing the recorded reading.
  String get explanation =>
      'Your recorded blood pressure was $systolic/$diastolic mmHg. '
      'The systolic value falls within the $systolicRangeLabel range and '
      'the diastolic value falls within the $diastolicRangeLabel range. '
      'This classification describes this recorded reading. It is not a diagnosis.';
}
