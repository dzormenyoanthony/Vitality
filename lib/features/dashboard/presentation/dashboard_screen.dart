import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/errors/failure.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
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
            tooltip: 'Scan BP report',
            onPressed: () => showScanEntrySheet(context, ref),
            child: const Icon(Icons.document_scanner_outlined, color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.sm),
          FloatingActionButton.extended(
            heroTag: 'dashboard-fab',
            backgroundColor: AppColors.dashboardAccentCoral,
            onPressed: () => context.push(AppRoutes.recordBp),
            icon: const Icon(Icons.add),
            label: const Text('Add reading'),
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
            "You haven't recorded a blood pressure reading yet. "
            'Tap "Add reading" to add your first one.',
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
    final now = DateTime.now();
    final hour = now.hour;
    final timeOfDay = hour < 12 ? 'morning' : (hour < 18 ? 'afternoon' : 'evening');
    final greeting = displayName == null
        ? 'Good $timeOfDay'
        : 'Good $timeOfDay, $displayName';
    const weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ]; // ignore: prefer_const_declarations
    final dateLabel = '${weekdayNames[now.weekday - 1]} ${now.day} ${monthNames[now.month - 1]}';

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
                '$dateLabel · $readingsThisWeek reading${readingsThisWeek == 1 ? '' : 's'} this week',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Tooltip(
          message: 'Settings',
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
                  'LOGGING STREAK',
                  style: theme.textTheme.labelMedium?.copyWith(color: accents.mintForeground),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '$streak day${streak == 1 ? '' : 's'}',
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
    await ref
        .read(reminderControllerProvider.notifier)
        .save(
          label: widget.insight.suggestedHour < 12 ? 'Morning reading' : 'Evening reading',
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
    ).showSnackBar(const SnackBar(content: Text('Reminder created.')));
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();
    final theme = Theme.of(context);
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
                'VITALY',
                style: theme.textTheme.labelSmall?.copyWith(color: accents.purpleForeground),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            widget.insight.message,
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
                  'Set ${_formatHourMinute(widget.insight.suggestedHour, widget.insight.suggestedMinute)} reminder',
                ),
              ),
              OutlinedButton(
                onPressed: _isSaving ? null : () => setState(() => _dismissed = true),
                style: OutlinedButton.styleFrom(foregroundColor: accents.purpleForeground),
                child: const Text('Not now'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatHourMinute(int hour, int minute) {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _NextReminderTile extends StatelessWidget {
  const _NextReminderTile({required this.occurrence});

  final NextReminderOccurrence? occurrence;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                'NEXT REMINDER',
                style: theme.textTheme.labelMedium?.copyWith(color: accents.coralForeground),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                occ == null ? 'No reminders set. Tap to add one.' : _formatWhen(occ.when),
                style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatWhen(DateTime when) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(when.year, when.month, when.day);
    final dayDiff = target.difference(today).inDays;
    const weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayLabel = switch (dayDiff) {
      0 => 'Today',
      1 => 'Tomorrow',
      _ => weekdayNames[when.weekday - 1],
    };
    final hh = when.hour.toString().padLeft(2, '0');
    final mm = when.minute.toString().padLeft(2, '0');
    return '$dayLabel $hh:$mm';
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
                  Text(
                    'LATEST READING',
                    style: theme.textTheme.labelMedium?.copyWith(color: Colors.white70),
                  ),
                  const Spacer(),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        _formatRecency(reading.timestamp),
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
                      child: Text('mmHg', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70)),
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
              Text(_subtitleFor(reading), style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white)),
              const SizedBox(height: AppSpacing.md),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(child: _AverageColumn(label: '7-DAY AVERAGE', stats: weekly)),
                  Expanded(child: _AverageColumn(label: '30-DAY AVERAGE', stats: monthly)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitleFor(BloodPressureReading reading) {
    final parts = <String>[];
    if (reading.pulse != null) parts.add('Pulse ${reading.pulse} bpm');
    final contextParts = <String>[];
    if (reading.bodyPosition != null) contextParts.add(reading.bodyPosition!.label);
    contextParts.addAll(reading.measurementContexts.map((c) => c.label.toLowerCase()));
    if (contextParts.isNotEmpty) parts.add(contextParts.join(', '));
    return parts.join(' · ');
  }

  String _formatRecency(DateTime ts) {
    final now = DateTime.now();
    final hh = ts.hour.toString().padLeft(2, '0');
    final mm = ts.minute.toString().padLeft(2, '0');
    if (ts.year == now.year && ts.month == now.month && ts.day == now.day) {
      return 'Today $hh:$mm';
    }
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ]; // ignore: prefer_const_declarations
    return '${monthNames[ts.month - 1]} ${ts.day}, $hh:$mm';
  }
}

class _AverageColumn extends StatelessWidget {
  const _AverageColumn({required this.label, required this.stats});

  final String label;
  final TrendStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                  child: Text('mmHg', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
                ),
              ],
            ),
          )
        else
          Text('No data', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70)),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            style: theme.textTheme.labelMedium,
            children: [
              const TextSpan(text: 'LAST 7 DAYS · '),
              TextSpan(
                text: 'systolic',
                style: TextStyle(color: AppColors.dashboardAccentTeal),
              ),
              TextSpan(text: ' / ', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
              TextSpan(
                text: 'diastolic',
                style: TextStyle(color: AppColors.dashboardAccentCoral),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
            child: readings.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Text('No readings recorded in the last 7 days.'),
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
      label:
          'Blood pressure trend for the last 7 days. See the latest reading '
          'card for the averages.',
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
