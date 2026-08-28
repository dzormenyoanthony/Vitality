import 'bp_classification.dart';
import 'bp_reference_ranges.dart';

/// The single centralized classifier for blood-pressure readings and
/// averages (PROJECT_SPEC.md §18). Every screen that shows a BP status —
/// Dashboard, History, Trends, Reading detail, Reports — must go through
/// this service; no other code may classify a reading independently or
/// hard-code a threshold (§18, §31).
///
/// This classifies the RECORDED VALUE, not the user. It never diagnoses,
/// never recommends treatment, and never makes an emergency determination
/// (§30) — it only maps numbers to the non-diagnostic categories in
/// [BPCategory].
abstract final class BPClassificationService {
  /// Classifies a single systolic/diastolic pair. Also used for calculated
  /// averages — the "this is an average of N readings" framing is a
  /// presentation-layer concern (PROJECT_SPEC.md §23), not part of this
  /// service.
  static BPClassification classify({required int systolic, required int diastolic}) {
    final systolicCategory = _classifySystolic(systolic);
    final diastolicCategory = _classifyDiastolic(diastolic);

    // Evaluated independently; the higher (more severe) of the two wins —
    // never averaged (PROJECT_SPEC.md §20).
    final category = systolicCategory.index >= diastolicCategory.index
        ? systolicCategory
        : diastolicCategory;

    return BPClassification(
      category: category,
      systolic: systolic,
      diastolic: diastolic,
      systolicRangeLabel: _systolicRangeLabel(systolicCategory),
      diastolicRangeLabel: _diastolicRangeLabel(diastolicCategory),
    );
  }

  static BPCategory _classifySystolic(int systolic) {
    if (systolic <= BPReferenceRanges.normalMaxSystolic) return BPCategory.normal;
    if (systolic <= BPReferenceRanges.elevatedMaxSystolic) return BPCategory.elevated;
    if (systolic <= BPReferenceRanges.higherMaxSystolic) return BPCategory.higher;
    return BPCategory.high;
  }

  /// No diastolic-only "elevated" tier exists — the ELEVATED category only
  /// applies when diastolic is normal too (PROJECT_SPEC.md §19).
  static BPCategory _classifyDiastolic(int diastolic) {
    if (diastolic <= BPReferenceRanges.normalMaxDiastolic) return BPCategory.normal;
    if (diastolic <= BPReferenceRanges.higherMaxDiastolic) return BPCategory.higher;
    return BPCategory.high;
  }

  static String _systolicRangeLabel(BPCategory category) => switch (category) {
    BPCategory.normal => '<${BPReferenceRanges.normalMaxSystolic + 1}',
    BPCategory.elevated =>
      '${BPReferenceRanges.normalMaxSystolic + 1}–${BPReferenceRanges.elevatedMaxSystolic}',
    BPCategory.higher =>
      '${BPReferenceRanges.elevatedMaxSystolic + 1}–${BPReferenceRanges.higherMaxSystolic}',
    BPCategory.high => '≥${BPReferenceRanges.higherMaxSystolic + 1}',
  };

  static String _diastolicRangeLabel(BPCategory category) => switch (category) {
    BPCategory.normal => '<${BPReferenceRanges.normalMaxDiastolic + 1}',
    BPCategory.elevated => '<${BPReferenceRanges.normalMaxDiastolic + 1}',
    BPCategory.higher =>
      '${BPReferenceRanges.normalMaxDiastolic + 1}–${BPReferenceRanges.higherMaxDiastolic}',
    BPCategory.high => '≥${BPReferenceRanges.higherMaxDiastolic + 1}',
  };
}
