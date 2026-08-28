import 'bp_classification_service.dart';
import 'trend_calculator.dart';

/// The exact non-diagnostic sentences shown in Trends' summary card
/// (PROJECT_SPEC.md §12) — extracted so the on-screen card and the PDF
/// export render identical copy from one source, rather than risking the
/// two drifting apart.
List<String> trendSummaryLines(TrendStats stats) {
  return [
    if (stats.avgSystolic != null)
      'Your average systolic reading over the last ${_periodDescription(stats.period)} '
          'was ${stats.avgSystolic!.round()} mmHg.',
    if (stats.avgDiastolic != null)
      'Your average diastolic reading over the last ${_periodDescription(stats.period)} '
          'was ${stats.avgDiastolic!.round()} mmHg.',
    if (stats.avgPulse != null)
      'Your average pulse over the last ${_periodDescription(stats.period)} '
          'was ${stats.avgPulse!.round()} bpm.',
    if (stats.avgSystolic != null && stats.avgDiastolic != null)
      'Average status (${stats.readingCount} reading${stats.readingCount == 1 ? '' : 's'}): '
          '${BPClassificationService.classify(
        systolic: stats.avgSystolic!.round(),
        diastolic: stats.avgDiastolic!.round(),
      ).category.label}.',
    'You recorded ${stats.readingCount} reading${stats.readingCount == 1 ? '' : 's'} '
        'during this period.',
    if (stats.previousPeriodReadingCount != null)
      _frequencyComparison(stats.readingCount, stats.previousPeriodReadingCount!),
    ?categoryMovementLine(stats),
  ];
}

/// "Your average recorded reading moved from the X category to the Y
/// category" (PROJECT_SPEC.md §27) — only shown when there's an actual
/// change, and always phrased as a category change, never a health
/// improvement/decline (§27, §29: never "your hypertension improved").
String? categoryMovementLine(TrendStats stats) {
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

  return 'Your average recorded reading moved from the ${previous.name} category '
      'to the ${current.name} category.';
}

String _periodDescription(TrendPeriod period) =>
    period == TrendPeriod.all ? 'available history' : period.label;

String _frequencyComparison(int current, int previous) {
  if (current == previous) return 'You recorded the same number of readings as last period.';
  return current < previous
      ? 'You recorded fewer readings this period than last.'
      : 'You recorded more readings this period than last.';
}
