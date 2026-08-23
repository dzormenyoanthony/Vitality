import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/errors/failure.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../data/blood_pressure_providers.dart';
import '../data/blood_pressure_reading.dart';
import '../domain/trend_calculator.dart';

/// Blood-pressure trend visualization (PROJECT_SPEC.md §11).
///
/// All copy here must stay within the non-diagnostic phrasing §12
/// explicitly approves — averages, counts, and reading-frequency
/// comparisons only. No reference bands, thresholds, or color-coded zones
/// are drawn on the charts (§14 classification remains deferred).
class TrendsScreen extends ConsumerStatefulWidget {
  const TrendsScreen({super.key});

  @override
  ConsumerState<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends ConsumerState<TrendsScreen> {
  TrendPeriod _period = TrendPeriod.sevenDays;

  @override
  Widget build(BuildContext context) {
    final readingsState = ref.watch(readingsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Trends')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SegmentedButton<TrendPeriod>(
              segments: TrendPeriod.values
                  .map((p) => ButtonSegment(value: p, label: Text(p.label)))
                  .toList(),
              selected: {_period},
              onSelectionChanged: (selected) => setState(() => _period = selected.first),
            ),
          ),
          Expanded(
            child: readingsState.when(
              loading: () => const LoadingIndicator(),
              error: (error, _) => ErrorView(
                message: friendlyMessage(error),
                onRetry: () => ref.invalidate(readingsStreamProvider),
              ),
              data: (readings) {
                final stats = TrendCalculator.compute(readings, _period, DateTime.now());
                if (stats.readingCount == 0) {
                  return const EmptyView(
                    message: 'No readings in this period yet.',
                    icon: Icons.show_chart,
                  );
                }
                return _TrendBody(stats: stats);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendBody extends StatelessWidget {
  const _TrendBody({required this.stats});

  final TrendStats stats;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _BpChart(readings: stats.readings),
        const SizedBox(height: AppSpacing.md),
        const _Legend(),
        if (stats.hasPulseData) ...[
          const SizedBox(height: AppSpacing.lg),
          Text('Pulse', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          _PulseChart(readings: stats.readings),
        ],
        const SizedBox(height: AppSpacing.lg),
        _StatsCard(stats: stats),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 16, height: 3, color: theme.colorScheme.primary),
        const SizedBox(width: AppSpacing.xs),
        const Text('Systolic'),
        const SizedBox(width: AppSpacing.lg),
        _DashedSwatch(color: theme.colorScheme.secondary),
        const SizedBox(width: AppSpacing.xs),
        const Text('Diastolic (dashed)'),
      ],
    );
  }
}

/// A short dashed line, so the legend conveys the diastolic line's dash
/// pattern by shape (not just its color) — PROJECT_SPEC.md §35.
class _DashedSwatch extends StatelessWidget {
  const _DashedSwatch({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 3,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final dash in [true, false, true, false, true])
            Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Container(
                width: 4,
                height: 3,
                color: dash ? color : Colors.transparent,
              ),
            ),
        ],
      ),
    );
  }
}

class _BpChart extends StatelessWidget {
  const _BpChart({required this.readings});

  final List<BloodPressureReading> readings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final systolicSpots = <FlSpot>[];
    final diastolicSpots = <FlSpot>[];
    for (var i = 0; i < readings.length; i++) {
      systolicSpots.add(FlSpot(i.toDouble(), readings[i].systolic.toDouble()));
      diastolicSpots.add(FlSpot(i.toDouble(), readings[i].diastolic.toDouble()));
    }

    return Semantics(
      label:
          'Blood pressure trend chart. See the summary below for averages '
          'and reading count.',
      child: ExcludeSemantics(
        child: SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              titlesData: _dateTitlesData(readings, theme),
              gridData: const FlGridData(drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              lineTouchData: const LineTouchData(enabled: false),
              lineBarsData: [
                LineChartBarData(
                  spots: systolicSpots,
                  color: theme.colorScheme.primary,
                  barWidth: 2.5,
                  // A line needs 2+ points to be visible; show a dot
                  // instead so a single reading isn't rendered as an
                  // empty chart.
                  dotData: FlDotData(show: systolicSpots.length < 2),
                ),
                LineChartBarData(
                  spots: diastolicSpots,
                  color: theme.colorScheme.secondary,
                  barWidth: 2.5,
                  dashArray: const [6, 4],
                  dotData: FlDotData(show: diastolicSpots.length < 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PulseChart extends StatelessWidget {
  const _PulseChart({required this.readings});

  final List<BloodPressureReading> readings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spots = <FlSpot>[];
    for (var i = 0; i < readings.length; i++) {
      final pulse = readings[i].pulse;
      if (pulse != null) spots.add(FlSpot(i.toDouble(), pulse.toDouble()));
    }

    return Semantics(
      label: 'Pulse trend chart. See the summary below for averages.',
      child: ExcludeSemantics(
        child: SizedBox(
          height: 160,
          child: LineChart(
            LineChartData(
              titlesData: _dateTitlesData(readings, theme),
              gridData: const FlGridData(drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              lineTouchData: const LineTouchData(enabled: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  color: theme.colorScheme.tertiary,
                  barWidth: 2.5,
                  dotData: FlDotData(show: spots.length < 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

FlTitlesData _dateTitlesData(List<BloodPressureReading> readings, ThemeData theme) {
  // Explicit theme-aware color so axis labels stay readable in dark mode
  // instead of falling back to fl_chart's non-theme-aware default style
  // (PROJECT_SPEC.md §35: "chart labels" need sufficient contrast).
  final axisStyle = theme.textTheme.bodySmall?.copyWith(
    color: theme.colorScheme.onSurfaceVariant,
  );

  String labelFor(double x) {
    final index = x.round();
    if (index < 0 || index >= readings.length) return '';
    final ts = readings[index].timestamp;
    return '${ts.month}/${ts.day}';
  }

  return FlTitlesData(
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 36,
        getTitlesWidget: (value, meta) =>
            Text(value.round().toString(), style: axisStyle),
      ),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 24,
        interval: readings.length > 1 ? (readings.length - 1).toDouble() : 1,
        getTitlesWidget: (value, meta) => Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(labelFor(value), style: axisStyle),
        ),
      ),
    ),
  );
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.stats});

  final TrendStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lines = <String>[
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final line in lines)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(line, style: theme.textTheme.bodyLarge),
              ),
          ],
        ),
      ),
    );
  }

  String _periodDescription(TrendPeriod period) =>
      period == TrendPeriod.all ? 'available history' : period.label;

  String _frequencyComparison(int current, int previous) {
    if (current == previous) return 'You recorded the same number of readings as last period.';
    return current < previous
        ? 'You recorded fewer readings this period than last.'
        : 'You recorded more readings this period than last.';
  }
}
