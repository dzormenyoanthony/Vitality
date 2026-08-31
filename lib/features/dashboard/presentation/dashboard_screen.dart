import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/errors/failure.dart';
import '../../../core/i18n/formatters.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../l10n/app_localizations.dart';
import '../../authentication/data/auth_providers.dart';
import '../../blood_pressure/data/blood_pressure_providers.dart';
import '../../blood_pressure/data/blood_pressure_reading.dart';
import '../../blood_pressure/domain/bp_classification_service.dart';
import '../../blood_pressure/domain/logging_streak.dart';
import '../../blood_pressure/domain/trend_calculator.dart';
import '../../blood_pressure/presentation/bp_status_badge.dart';
import '../../blood_pressure/presentation/measurement_context_label.dart';
import '../../onboarding/data/user_profile_providers.dart';
import '../../reminders/data/reminder.dart';
import '../../reminders/data/reminder_providers.dart';
import '../../reminders/domain/next_reminder.dart';
import '../../reminders/presentation/reminder_controller.dart';
import '../../reports/presentation/scan_entry_sheet.dart';
import '../domain/logging_insight.dart';

/// Vitaly's home dashboard (PROJECT_SPEC.md §10): a greeting, the latest
/// reading with 7/30-day averages, a logging streak, a rule-based
/// logging-pattern nudge, the next reminder, and a 7-day trend chart.
///
/// Visual design matches `design_references/Dashboard.png`.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final uid = ref.watch(authStateChangesProvider).value?.uid;
    final profile = uid == null ? null : ref.watch(userProfileStreamProvider(uid)).value;
    final readingsState = ref.watch(readingsStreamProvider);
    // Reminders degrade gracefully if unavailable — the rest of the
    // dashboard shouldn't block on a secondary summary card.
    final reminders = ref.watch(remindersStreamProvider).value ?? [];

    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            // Unique per screen: the bottom-nav shell keeps every tab (and
            // any route pushed on top) mounted simultaneously, so default
            // hero tags collide across FABs on different screens.
            heroTag: 'dashboard-scan-fab',
            mini: true,
            backgroundColor: AppColors.dashboardAccentTeal,
            tooltip: l10n.dashboardScanFabTooltip,
            onPressed: () => showScanEntrySheet(context, ref),
            child: const Icon(Icons.document_scanner_outlined, color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.sm),
          FloatingActionButton.extended(
            heroTag: 'dashboard-fab',
            backgroundColor: AppColors.dashboardAccentCoral,
            onPressed: () => context.push(AppRoutes.recordBp),
            icon: const Icon(Icons.add),
            label: Text(l10n.dashboardAddReading),
          ),
        ],
      ),
      body: SafeArea(
        child: readingsState.when(
          loading: () => const LoadingIndicator(),
          error: (error, _) => ErrorView(
            message: friendlyMessage(error),
            onRetry: () => ref.invalidate(readingsStreamProvider),
          ),
          data: (readings) => _DashboardBody(
            displayName: profile?.displayName,
            readings: readings,
            reminders: reminders,
          ),
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.displayName,
    required this.readings,
    required this.reminders,
  });

  final String? displayName;
  final List<BloodPressureReading> readings;
  final List<Reminder> reminders;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final nextReminder = NextReminderCalculator.compute(reminders, now);
    final weekly = TrendCalculator.compute(readings, TrendPeriod.sevenDays, now);

    if (readings.isEmpty) {
      return ListView(
        // Extra bottom padding so the last card can scroll clear of the
        // "Add reading" FAB, which otherwise overlaps and blocks taps on
        // content near the bottom of the list.
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg + AppSpacing.xxl,
        ),
        children: [
          _Header(displayName: displayName, readingsThisWeek: 0),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.dashboardEmptyBody,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          _NextReminderTile(occurrence: nextReminder),
        ],
      );
    }

    final streak = computeLoggingStreak(readings, now);
    final insight = computeLoggingInsight(readings, now);
    final latest = readings.first;
    final monthly = TrendCalculator.compute(readings, TrendPeriod.thirtyDays, now);

    return ListView(
      // Extra bottom padding so the chart card can scroll clear of the
      // "Add reading" FAB, which otherwise overlaps and blocks taps on
      // content near the bottom of the list.
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg + AppSpacing.xxl,
      ),
      children: [
        _Header(displayName: displayName, readingsThisWeek: weekly.readingCount),
        const SizedBox(height: AppSpacing.lg),
        _LatestReadingCard(reading: latest, weekly: weekly, monthly: monthly),
        if (insight != null) ...[
          const SizedBox(height: AppSpacing.lg),
          _InsightCard(insight: insight),
        ],
        const SizedBox(height: AppSpacing.lg),
        if (streak > 1)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _NextReminderTile(occurrence: nextReminder)),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _StreakTile(streak: streak)),
              ],
            ),
          )
        else
          _NextReminderTile(occurrence: nextReminder),
        const SizedBox(height: AppSpacing.lg),
        _WeeklyChartCard(readings: weekly.readings),
      ],
    );
  }
}

/// Greeting + date/count row with a badge linking to Settings — matches
/// `design_references/Dashboard.png`'s header exactly, in place of a
/// standard AppBar.
class _Header extends StatelessWidget {
  const _Header({required this.displayName, required this.readingsThisWeek});

  final String? displayName;
  final int readingsThisWeek;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final hour = now.hour;
    final timeOfDay = hour < 12
        ? l10n.dashboardTimeOfDayMorning
        : (hour < 18
            ? l10n.dashboardTimeOfDayAfternoon
            : l10n.dashboardTimeOfDayEvening);
    final greeting = displayName == null
        ? l10n.dashboardGreeting(timeOfDay)
        : l10n.dashboardGreetingWithName(timeOfDay, displayName!);
    final dateLabel = formatWeekdayDayMonth(context, now);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting, style: theme.textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.dashboardHeaderSubtitle(dateLabel, readingsThisWeek),
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Tooltip(
          message: l10n.settingsTitle,
          child: Material(
            color: AppColors.dashboardBadgeBackground,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              onTap: () => context.push(AppRoutes.settings),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm + 2),
                child: Icon(Icons.settings_outlined, color: AppColors.heroFill),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StreakTile extends StatelessWidget {
  const _StreakTile({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final accents = theme.extension<AppAccentColors>() ?? AppAccentColors.light;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: accents.mintBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_fire_department, size: 16, color: accents.mintForeground),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  l10n.dashboardStreakLabel,
                  style: theme.textTheme.labelMedium?.copyWith(color: accents.mintForeground),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.dashboardStreakDays(streak),
            style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface),
          ),
        ],
      ),
    );
  }
}

/// Rule-based nudge derived only from logging counts/patterns — never a
/// comment on reading values (PROJECT_SPEC.md §12-14). Dismissal is
/// session-only (not persisted), matching a lightweight "not now" prompt.
class _InsightCard extends ConsumerStatefulWidget {
  const _InsightCard({required this.insight});

  final LoggingInsight insight;

  @override
  ConsumerState<_InsightCard> createState() => _InsightCardState();
}

class _InsightCardState extends ConsumerState<_InsightCard> {
  bool _dismissed = false;
  bool _isSaving = false;

  Future<void> _setReminder() async {
    setState(() => _isSaving = true);
    final l10n = AppLocalizations.of(context);
    await ref
        .read(reminderControllerProvider.notifier)
        .save(
          label: widget.insight.suggestedHour < 12
              ? l10n.reminderDefaultLabelMorning
              : l10n.reminderDefaultLabelEvening,
          hour: widget.insight.suggestedHour,
          minute: widget.insight.suggestedMinute,
          daysOfWeek: const {1, 2, 3, 4, 5, 6, 7},
        );
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _dismissed = true;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.reminderCreatedSnackbar)));
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final accents = theme.extension<AppAccentColors>() ?? AppAccentColors.light;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: accents.purpleBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: accents.purpleForeground, shape: BoxShape.circle),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                l10n.splashWordmark,
                style: theme.textTheme.labelSmall?.copyWith(color: accents.purpleForeground),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            switch (widget.insight.kind) {
              LoggingInsightKind.morningGap => l10n.loggingInsightMorningGap(
                widget.insight.morningDays,
                widget.insight.eveningDays,
              ),
              LoggingInsightKind.eveningGap => l10n.loggingInsightEveningGap(
                widget.insight.eveningDays,
                widget.insight.morningDays,
              ),
            },
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              FilledButton(
                onPressed: _isSaving ? null : _setReminder,
                style: FilledButton.styleFrom(backgroundColor: accents.purpleForeground),
                child: Text(
                  l10n.dashboardSetReminderButton(
                    formatClock(
                      context,
                      hour: widget.insight.suggestedHour,
                      minute: widget.insight.suggestedMinute,
                    ),
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: _isSaving ? null : () => setState(() => _dismissed = true),
                style: OutlinedButton.styleFrom(foregroundColor: accents.purpleForeground),
                child: Text(l10n.commonNotNow),
              ),
            ],
          ),
        ],
      ),
    );
  }

}

class _NextReminderTile extends StatelessWidget {
  const _NextReminderTile({required this.occurrence});

  final NextReminderOccurrence? occurrence;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final accents = theme.extension<AppAccentColors>() ?? AppAccentColors.light;
    final occ = occurrence;

    return Material(
      color: accents.coralBackground,
      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        onTap: () => context.push(AppRoutes.reminders),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.dashboardNextReminderLabel,
                style: theme.textTheme.labelMedium?.copyWith(color: accents.coralForeground),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                occ == null ? l10n.dashboardNoReminders : _formatWhen(context, l10n, occ.when),
                style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatWhen(BuildContext context, AppLocalizations l10n, DateTime when) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(when.year, when.month, when.day);
    final dayDiff = target.difference(today).inDays;
    final dayLabel = switch (dayDiff) {
      0 => l10n.commonToday,
      1 => l10n.commonTomorrow,
      _ => formatWeekdayAbbrev(context, when),
    };
    return l10n.dashboardNextReminderWhen(dayLabel, formatTime(context, when));
  }
}

class _LatestReadingCard extends StatelessWidget {
  const _LatestReadingCard({required this.reading, required this.weekly, required this.monthly});

  final BloodPressureReading reading;
  final TrendStats weekly;
  final TrendStats monthly;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final classification = BPClassificationService.classify(
      systolic: reading.systolic,
      diastolic: reading.diastolic,
    );

    return Material(
      color: AppColors.heroFill,
      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        onTap: () => context.push(AppRoutes.readingDetailPath(reading.id)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      l10n.dashboardLatestReadingLabel,
                      style: theme.textTheme.labelMedium?.copyWith(color: Colors.white70),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        _formatRecency(context, l10n, reading.timestamp),
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${reading.systolic}',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('/', style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white54)),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${reading.diastolic}',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(l10n.unitMmhg, style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              BPStatusBadge(
                classification: classification,
                onExplain: () => showBpExplanationSheet(context, classification),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(_subtitleFor(l10n, reading), style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white)),
              const SizedBox(height: AppSpacing.md),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(child: _AverageColumn(label: l10n.dashboardSevenDayAverage, stats: weekly)),
                  Expanded(child: _AverageColumn(label: l10n.dashboardThirtyDayAverage, stats: monthly)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitleFor(AppLocalizations l10n, BloodPressureReading reading) {
    final parts = <String>[];
    if (reading.pulse != null) parts.add(l10n.dashboardPulseSummary(reading.pulse!));
    final contextParts = <String>[];
    if (reading.bodyPosition != null) contextParts.add(reading.bodyPosition!.label(l10n));
    contextParts.addAll(reading.measurementContexts.map((c) => c.label(l10n).toLowerCase()));
    if (contextParts.isNotEmpty) parts.add(contextParts.join(', '));
    return parts.join(' · ');
  }

  String _formatRecency(BuildContext context, AppLocalizations l10n, DateTime ts) {
    final now = DateTime.now();
    final time = formatTime(context, ts);
    if (ts.year == now.year && ts.month == now.month && ts.day == now.day) {
      return '${l10n.commonToday} $time';
    }
    return '${formatDayMonth(context, ts)}, $time';
  }
}

class _AverageColumn extends StatelessWidget {
  const _AverageColumn({required this.label, required this.stats});

  final String label;
  final TrendStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final avgSystolic = stats.avgSystolic;
    final avgDiastolic = stats.avgDiastolic;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium?.copyWith(color: Colors.white70)),
        const SizedBox(height: AppSpacing.xs),
        if (avgSystolic != null && avgDiastolic != null)
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${avgSystolic.round()}/${avgDiastolic.round()}',
                  style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(width: AppSpacing.xs),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(l10n.unitMmhg, style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
                ),
              ],
            ),
          )
        else
          Text(l10n.commonNoData, style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70)),
      ],
    );
  }
}

/// 7-day systolic/diastolic trend chart — matches
/// `design_references/Dashboard.png`'s "LAST 7 DAYS" card.
class _WeeklyChartCard extends StatelessWidget {
  const _WeeklyChartCard({required this.readings});

  final List<BloodPressureReading> readings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            style: theme.textTheme.labelMedium,
            children: [
              TextSpan(text: l10n.dashboardChartLegendPrefix),
              TextSpan(
                text: l10n.bpSeriesSystolic,
                style: const TextStyle(color: AppColors.dashboardAccentTeal),
              ),
              TextSpan(text: ' / ', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
              TextSpan(
                text: l10n.bpSeriesDiastolic,
                style: const TextStyle(color: AppColors.dashboardAccentCoral),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
            child: readings.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(l10n.dashboardChartEmpty),
                  )
                : _WeeklyChart(readings: readings),
          ),
        ),
      ],
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.readings});

  final List<BloodPressureReading> readings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final axisStyle = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final systolicSpots = <FlSpot>[];
    final diastolicSpots = <FlSpot>[];
    for (var i = 0; i < readings.length; i++) {
      systolicSpots.add(FlSpot(i.toDouble(), readings[i].systolic.toDouble()));
      diastolicSpots.add(FlSpot(i.toDouble(), readings[i].diastolic.toDouble()));
    }

    // Fit the Y axis to the actual data (with padding) instead of a fixed
    // range — a fixed range let out-of-range readings (e.g. a systolic
    // above a hard-coded max) draw past the chart's visible bounds.
    final allValues = [
      for (final r in readings) r.systolic.toDouble(),
      for (final r in readings) r.diastolic.toDouble(),
    ];
    final dataMin = allValues.reduce((a, b) => a < b ? a : b);
    final dataMax = allValues.reduce((a, b) => a > b ? a : b);
    final chartMinY = ((dataMin - 10) / 10).floor() * 10.0;
    final chartMaxY = ((dataMax + 10) / 10).ceil() * 10.0;
    final interval = ((chartMaxY - chartMinY) / 3 / 10).ceil() * 10.0;

    return Semantics(
      label: l10n.dashboardChartSemantics,
      child: ExcludeSemantics(
        child: SizedBox(
          height: 160,
          child: LineChart(
            LineChartData(
              minY: chartMinY,
              maxY: chartMaxY,
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: interval,
                    getTitlesWidget: (value, meta) => Text(value.round().toString(), style: axisStyle),
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
                  dotData: FlDotData(show: systolicSpots.length < 2),
                ),
                LineChartBarData(
                  spots: diastolicSpots,
                  color: AppColors.dashboardAccentCoral,
                  barWidth: 2.5,
                  isCurved: false,
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
