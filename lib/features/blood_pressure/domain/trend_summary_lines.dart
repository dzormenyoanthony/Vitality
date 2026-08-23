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
    'You recorded ${stats.readingCount} reading${stats.readingCount == 1 ? '' : 's'} '
        'during this period.',
    if (stats.previousPeriodReadingCount != null)
      _frequencyComparison(stats.readingCount, stats.previousPeriodReadingCount!),
  ];
}

String _periodDescription(TrendPeriod period) =>
    period == TrendPeriod.all ? 'available history' : period.label;

String _frequencyComparison(int current, int previous) {
  if (current == previous) return 'You recorded the same number of readings as last period.';
  return current < previous
      ? 'You recorded fewer readings this period than last.'
      : 'You recorded more readings this period than last.';
}
