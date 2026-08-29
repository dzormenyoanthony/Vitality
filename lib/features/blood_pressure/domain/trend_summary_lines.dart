import '../../../l10n/app_localizations.dart';
import 'bp_classification.dart';
import 'bp_classification_service.dart';
import 'trend_calculator.dart';

/// The exact non-diagnostic sentences shown in Trends' summary card
/// (PROJECT_SPEC.md §12) — built from [AppLocalizations] so the on-screen
/// card and the PDF export render identical copy from one source, rather
/// than risking the two drifting apart.
List<String> trendSummaryLines(AppLocalizations l10n, TrendStats stats) {
  final period = _periodDescription(l10n, stats.period);
  return [
    if (stats.avgSystolic != null)
      l10n.trendSummaryAvgSystolic(period, stats.avgSystolic!.round()),
    if (stats.avgDiastolic != null)
      l10n.trendSummaryAvgDiastolic(period, stats.avgDiastolic!.round()),
    if (stats.avgPulse != null)
      l10n.trendSummaryAvgPulse(period, stats.avgPulse!.round()),
    if (stats.avgSystolic != null && stats.avgDiastolic != null)
      l10n.trendSummaryAverageStatus(
        stats.readingCount,
        BPClassificationService.classify(
          systolic: stats.avgSystolic!.round(),
          diastolic: stats.avgDiastolic!.round(),
        ).category.label(l10n),
      ),
    l10n.trendSummaryReadingCount(stats.readingCount),
    if (stats.previousPeriodReadingCount != null)
      _frequencyComparison(
        l10n,
        stats.readingCount,
        stats.previousPeriodReadingCount!,
      ),
    ?categoryMovementLine(l10n, stats),
  ];
}

/// "Your average recorded reading moved from the X category to the Y
/// category" (PROJECT_SPEC.md §27) — only shown when there's an actual
/// change, and always phrased as a category change, never a health
/// improvement/decline (§27, §29: never "your hypertension improved").
String? categoryMovementLine(AppLocalizations l10n, TrendStats stats) {
  final avgSystolic = stats.avgSystolic;
  final avgDiastolic = stats.avgDiastolic;
  final previousAvgSystolic = stats.previousAvgSystolic;
  final previousAvgDiastolic = stats.previousAvgDiastolic;
  if (avgSystolic == null ||
      avgDiastolic == null ||
      previousAvgSystolic == null ||
      previousAvgDiastolic == null) {
    return null;
  }

  final current = BPClassificationService.classify(
    systolic: avgSystolic.round(),
    diastolic: avgDiastolic.round(),
  ).category;
  final previous = BPClassificationService.classify(
    systolic: previousAvgSystolic.round(),
    diastolic: previousAvgDiastolic.round(),
  ).category;
  if (current == previous) return null;

  return l10n.trendCategoryMovement(previous.noun(l10n), current.noun(l10n));
}

String _periodDescription(AppLocalizations l10n, TrendPeriod period) =>
    period == TrendPeriod.all
        ? l10n.trendSummaryPeriodAll
        : l10n.trendsPeriodName(period.name);

String _frequencyComparison(AppLocalizations l10n, int current, int previous) {
  if (current == previous) return l10n.trendFrequencySame;
  return current < previous
      ? l10n.trendFrequencyFewer
      : l10n.trendFrequencyMore;
}
