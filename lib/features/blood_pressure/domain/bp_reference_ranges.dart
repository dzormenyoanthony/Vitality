import 'bp_classification.dart';

/// Centralized, versioned blood-pressure reference thresholds
/// (PROJECT_SPEC.md §19, §31). [BPClassificationService] is the only code
/// that reads these — no other screen or service may hard-code a
/// threshold. A future clinically-reviewed update bumps [version] and
/// replaces these bounds, without changing any call site.
///
/// This is the initial framework proposed in PROJECT_SPEC.md §19; per §19
/// itself, the exact reference framework and wording must be clinically
/// reviewed before production launch.
abstract final class BPReferenceRanges {
  static const int version = 1;

  /// Systolic below this is [BPCategory.normal].
  static const int normalMaxSystolic = 119;

  /// Systolic below this (and above [normalMaxSystolic]) is
  /// [BPCategory.elevated].
  static const int elevatedMaxSystolic = 129;

  /// Systolic below this (and above [elevatedMaxSystolic]) is
  /// [BPCategory.higher]; at or above it is [BPCategory.high].
  static const int higherMaxSystolic = 139;

  /// Diastolic below this is [BPCategory.normal].
  static const int normalMaxDiastolic = 79;

  /// Diastolic below this (and above [normalMaxDiastolic]) is
  /// [BPCategory.higher] — there is no diastolic-only "elevated" tier
  /// (PROJECT_SPEC.md §19: ELEVATED requires diastolic < 80 as well).
  static const int higherMaxDiastolic = 89;
}
