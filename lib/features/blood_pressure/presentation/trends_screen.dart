import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/errors/failure.dart';
import '../../../core/i18n/formatters.dart';
import '../../../core/router/auth_gate_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../l10n/app_localizations.dart';
import '../../reports/data/report_providers.dart';
import '../data/blood_pressure_providers.dart';
import '../data/blood_pressure_reading.dart';
import '../domain/bp_classification_service.dart';
import '../domain/trend_calculator.dart';
import '../domain/trend_summary_lines.dart';
import 'bp_status_badge.dart';
import 'trend_pdf_export.dart';

/// The four period filters offered on Trends, matching
/// `design_references/Trends.png` — [TrendPeriod.all] remains available in
/// the domain layer for other callers, but isn't one of this screen's
/// filter chips.
const _chipPeriods = [
  TrendPeriod.sevenDays,
  TrendPeriod.thirtyDays,
  TrendPeriod.ninetyDays,
  TrendPeriod.oneYear,
];

/// Blood-pressure trend visualization (PROJECT_SPEC.md §11).
///
/// Visual design matches `design_references/Trends.png`. All copy here must
/// stay within the non-diagnostic phrasing §12 explicitly approves —
/// averages, counts, ranges, and reading-frequency comparisons only. No
/// reference bands, thresholds, or color-coded zones are drawn on the
/// charts (§14 classification remains deferred).
class TrendsScreen extends ConsumerStatefulWidget {
  const TrendsScreen({super.key});

  @override
  ConsumerState<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends ConsumerState<TrendsScreen> {
  TrendPeriod _period = TrendPeriod.sevenDays;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final readingsState = ref.watch(readingsStreamProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Text(l10n.navTrends, style: theme.textTheme.headlineMedium),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  for (final p in _chipPeriods)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: _PeriodChip(
                        label: l10n.trendsChipPeriod(p.name),
                        selected: p == _period,
                        onTap: () => setState(() => _period = p),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
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
                    return EmptyView(
                      message: l10n.trendsEmpty,
                      icon: Icons.show_chart,
                    );
                  }
                  return _TrendBody(stats: stats);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accents = theme.extension<AppAccentColors>() ?? AppAccentColors.light;

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? accents.mintBackground : theme.colorScheme.surface,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? AppColors.dashboardAccentTeal : theme.colorScheme.outlineVariant,
          ),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: selected ? accents.mintForeground : theme.colorScheme.onSurface,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
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
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxl),
      children: [
        _ChartCard(stats: stats),
        const SizedBox(height: AppSpacing.md),
        _StatsGrid(stats: stats),
        if (stats.avgSystolic != null && stats.avgDiastolic != null) ...[
          const SizedBox(height: AppSpacing.md),
          _AverageStatusCard(stats: stats),
        ],
        const SizedBox(height: AppSpacing.md),
        const _DisclaimerCard(),
        const SizedBox(height: AppSpacing.md),
        _ExportButton(stats: stats),
        if (stats.hasPulseData) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(AppLocalizations.of(context).trendsPulseSectionTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          _PulseChart(readings: stats.readings),
        ],
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.stats});

  final TrendStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).trendsChartHeader,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.dashboardAccentTeal,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    _dateRangeLabel(context, stats.readings),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _BpChart(readings: stats.readings),
            const SizedBox(height: AppSpacing.sm),
            const _Legend(),
          ],
        ),
      ),
    );
  }
}

String _dateRangeLabel(
  BuildContext context,
  List<BloodPressureReading> readings,
) {
  final first = formatDayMonth(context, readings.first.timestamp);
  final last = formatDayMonth(context, readings.last.timestamp);
  return '$first – $last';
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    // Wrap, not Row: at large system text sizes both legend labels can't
    // always fit on one line — wrapping the second item below keeps both
    // fully readable instead of overflowing horizontally.
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.xs,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 16, height: 3, color: AppColors.dashboardAccentTeal),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                l10n.trendsLegendSystolic,
                style: theme.textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DashedSwatch(color: AppColors.dashboardAccentCoral),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                l10n.trendsLegendDiastolic,
                style: theme.textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
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
    final axisStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final systolicSpots = <FlSpot>[];
    final diastolicSpots = <FlSpot>[];
    for (var i = 0; i < readings.length; i++) {
      systolicSpots.add(FlSpot(i.toDouble(), readings[i].systolic.toDouble()));
      diastolicSpots.add(FlSpot(i.toDouble(), readings[i].diastolic.toDouble()));
    }

    // Fit the Y axis to the actual data (with padding) instead of a fixed
    // range, so out-of-range readings never draw past the chart's bounds.
    final allValues = [
      for (final r in readings) r.systolic.toDouble(),
      for (final r in readings) r.diastolic.toDouble(),
    ];
    final dataMin = allValues.reduce((a, b) => a < b ? a : b);
    final dataMax = allValues.reduce((a, b) => a > b ? a : b);
    final chartMinY = ((dataMin - 10) / 10).floor() * 10.0;
    final chartMaxY = ((dataMax + 10) / 10).ceil() * 10.0;
    final interval = ((chartMaxY - chartMinY) / 4 / 10).ceil() * 10.0;

    final lastIndex = readings.length - 1;
    final midIndex = lastIndex ~/ 2;
    String labelFor(double x) {
      final index = x.round();
      if (index != 0 && index != midIndex && index != lastIndex) return '';
      if (index < 0 || index > lastIndex) return '';
      final ts = readings[index].timestamp;
      return formatDayMonth(context, ts);
    }

    bool isLastSpot(FlSpot spot, LineChartBarData barData) => spot.x == barData.spots.last.x;

    return Semantics(
      label: AppLocalizations.of(context).trendsChartSemantics,
      child: ExcludeSemantics(
        child: SizedBox(
          height: 240,
          child: LineChart(
            LineChartData(
              minY: chartMinY,
              maxY: chartMaxY,
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    interval: interval,
                    getTitlesWidget: (value, meta) =>
                        Text(value.round().toString(), style: axisStyle),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    interval: 1,
                    getTitlesWidget: (value, meta) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(labelFor(value), style: axisStyle),
                    ),
                  ),
                ),
              ),
              gridData: FlGridData(
                drawVerticalLine: false,
                horizontalInterval: interval,
                getDrawingHorizontalLine: (value) => FlLine(color: theme.dividerColor, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              lineTouchData: const LineTouchData(enabled: false),
              lineBarsData: [
                LineChartBarData(
                  spots: systolicSpots,
                  color: AppColors.dashboardAccentTeal,
                  barWidth: 2.5,
                  isCurved: false,
                  dotData: FlDotData(
                    show: true,
                    checkToShowDot: (spot, barData) =>
                        systolicSpots.length < 2 || isLastSpot(spot, barData),
                    getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                      radius: 4,
                      color: AppColors.dashboardAccentTeal,
                      strokeWidth: 0,
                    ),
                  ),
                ),
                LineChartBarData(
                  spots: diastolicSpots,
                  color: AppColors.dashboardAccentCoral,
                  barWidth: 2.5,
                  isCurved: false,
                  dashArray: const [6, 4],
                  dotData: FlDotData(
                    show: true,
                    checkToShowDot: (spot, barData) =>
                        diastolicSpots.length < 2 || isLastSpot(spot, barData),
                    getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                      radius: 4,
                      color: AppColors.dashboardAccentCoral,
                      strokeWidth: 0,
                    ),
                  ),
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
    final axisStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final spots = <FlSpot>[];
    for (var i = 0; i < readings.length; i++) {
      final pulse = readings[i].pulse;
      if (pulse != null) spots.add(FlSpot(i.toDouble(), pulse.toDouble()));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
        child: Semantics(
          label: AppLocalizations.of(context).trendsPulseChartSemantics,
          child: ExcludeSemantics(
            child: SizedBox(
              height: 160,
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) =>
                            Text(value.round().toString(), style: axisStyle),
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(color: theme.dividerColor, strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                  lineTouchData: const LineTouchData(enabled: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      color: theme.colorScheme.tertiary,
                      barWidth: 2.5,
                      isCurved: false,
                      dotData: FlDotData(show: spots.length < 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final TrendStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final accents = theme.extension<AppAccentColors>() ?? AppAccentColors.light;
    final readings = stats.readings;

    final avgSystolic = stats.avgSystolic;
    final avgDiastolic = stats.avgDiastolic;

    final systolicValues = readings.map((r) => r.systolic);
    final minSystolic = systolicValues.reduce((a, b) => a < b ? a : b);
    final maxSystolic = systolicValues.reduce((a, b) => a > b ? a : b);

    final distinctDays = readings
        .map((r) => DateTime(r.timestamp.year, r.timestamp.month, r.timestamp.day))
        .toSet()
        .length;
    final periodDays = stats.period.days ?? distinctDays;

    final morningAvg = _averageSystolic(readings.where((r) => r.timestamp.hour < 12));
    final eveningAvg = _averageSystolic(readings.where((r) => r.timestamp.hour >= 12));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _StatTile(
                background: accents.mintBackground,
                foreground: accents.mintForeground,
                label: l10n.trendsStatAverage,
                value: avgSystolic != null && avgDiastolic != null
                    ? '${avgSystolic.round()} / ${avgDiastolic.round()}'
                    : '–',
                subtitle: l10n.trendsStatAverageSubtitle(
                  l10n.trendsPeriodName(stats.period.name),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _StatTile(
                background: accents.purpleBackground,
                foreground: accents.purpleForeground,
                label: l10n.trendsStatReadings,
                value: '${stats.readingCount}',
                subtitle: l10n.trendsStatReadingsSubtitle(distinctDays, periodDays),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            children: [
              _StatTile(
                background: accents.coralBackground,
                foreground: accents.coralForeground,
                label: l10n.trendsStatRange,
                value: '$minSystolic–$maxSystolic',
                subtitle: l10n.trendsStatRangeSubtitle,
              ),
              const SizedBox(height: AppSpacing.sm),
              _StatTile(
                background: accents.blueBackground,
                foreground: accents.blueForeground,
                label: l10n.trendsStatMorningEvening,
                value:
                    '${morningAvg?.round() ?? '–'} / ${eveningAvg?.round() ?? '–'}',
                subtitle: l10n.trendsStatMorningEveningSubtitle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

double? _averageSystolic(Iterable<BloodPressureReading> readings) {
  final values = readings.map((r) => r.systolic).toList();
  if (values.isEmpty) return null;
  return values.reduce((a, b) => a + b) / values.length;
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.background,
    required this.foreground,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  final Color background;
  final Color foreground;
  final String label;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: foreground)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// The period average's status (PROJECT_SPEC.md §23, §27): always labeled
/// as an average of N readings — never phrased as a new measurement — and
/// includes a category-movement sentence versus the prior period when the
/// category actually changed.
class _AverageStatusCard extends StatelessWidget {
  const _AverageStatusCard({required this.stats});

  final TrendStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final classification = BPClassificationService.classify(
      systolic: stats.avgSystolic!.round(),
      diastolic: stats.avgDiastolic!.round(),
    );
    final movementLine = categoryMovementLine(l10n, stats);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BPStatusBadge(
              classification: classification,
              onExplain: () => showBpExplanationSheet(context, classification),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppLocalizations.of(context).trendsAverageOfReadings(stats.readingCount),
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            if (movementLine != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                movementLine,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The non-diagnostic disclaimer under the stat grid — PROJECT_SPEC.md §12
/// requires averages to be framed as records, never as an assessment.
///
/// Uses the theme-aware mint accent pair (not a fixed light color) so the
/// text stays legible against its own background in dark mode too.
class _DisclaimerCard extends StatelessWidget {
  const _DisclaimerCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accents = theme.extension<AppAccentColors>() ?? AppAccentColors.light;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: accents.mintBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Text(
        AppLocalizations.of(context).trendsDisclaimer,
        style: theme.textTheme.bodyMedium?.copyWith(color: accents.mintForeground),
      ),
    );
  }
}

class _ExportButton extends ConsumerWidget {
  const _ExportButton({required this.stats});

  final TrendStats stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _exportPdf(context, ref),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.dashboardAccentTeal,
          side: const BorderSide(color: AppColors.dashboardAccentTeal),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          textStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        icon: const Icon(Icons.download_outlined),
        label: Text(
          AppLocalizations.of(context).trendsExportButton(
            AppLocalizations.of(context).trendsExportPeriodName(stats.period.name),
          ),
        ),
      ),
    );
  }

  Future<void> _exportPdf(BuildContext context, WidgetRef ref) async {
    final gate = ref.read(authGateProvider);
    final bytes = await buildTrendSummaryPdf(
      AppLocalizations.of(context),
      stats,
      patientName: gate is AuthGateReady ? gate.displayName : null,
      reports: ref.read(savedReportsStreamProvider).value ?? const [],
    );
    if (!context.mounted) return;
    await Printing.sharePdf(bytes: bytes, filename: 'vitaly-trend-summary.pdf');
  }
}
