import '../../../l10n/app_localizations.dart';

/// A non-diagnostic status category for a recorded blood-pressure reading
/// or average (PROJECT_SPEC.md §18-21). This describes the RECORDED
/// VALUE, never the user's medical condition — see the approved wording in
/// [BPCategoryLabel.label] and §29's approved/avoid language lists.
///
/// Ordered by severity, lowest first — [index] doubles as the severity
/// rank used to pick "the higher applicable category" when systolic and
/// diastolic fall into different categories (§20).
enum BPCategory { normal, elevated, higher, high }

extension BPCategoryLabel on BPCategory {
  /// The approved, non-diagnostic display label (PROJECT_SPEC.md §21, §29).
  String label(AppLocalizations l10n) => switch (this) {
    BPCategory.normal => l10n.bpCategoryLooksGood,
    BPCategory.elevated => l10n.bpCategoryWorthKeepingAnEyeOn,
    BPCategory.higher => l10n.bpCategoryHigherThanUsual,
    BPCategory.high => l10n.bpCategoryReadingIsHigh,
  };

  /// Lowercase category noun for the trends category-movement sentence
  /// (PROJECT_SPEC.md §27).
  String noun(AppLocalizations l10n) => switch (this) {
    BPCategory.normal => l10n.bpCategoryNameNormal,
    BPCategory.elevated => l10n.bpCategoryNameElevated,
    BPCategory.higher => l10n.bpCategoryNameHigher,
    BPCategory.high => l10n.bpCategoryNameHigh,
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
  String explanation(AppLocalizations l10n) => l10n.bpExplanation(
    systolic,
    diastolic,
    systolicRangeLabel,
    diastolicRangeLabel,
  );
}
