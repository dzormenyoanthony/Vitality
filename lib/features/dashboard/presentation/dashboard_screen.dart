import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/errors/failure.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/tag_chip.dart';
import '../../authentication/data/auth_providers.dart';
import '../../blood_pressure/data/blood_pressure_providers.dart';
import '../../blood_pressure/data/blood_pressure_reading.dart';
import '../../blood_pressure/domain/logging_streak.dart';
import '../../blood_pressure/domain/trend_calculator.dart';
import '../../education/data/article.dart';
import '../../education/presentation/education_providers.dart';
import '../../onboarding/data/user_profile_providers.dart';
import '../../reminders/data/reminder.dart';
import '../../reminders/data/reminder_providers.dart';
import '../../reminders/domain/next_reminder.dart';
import '../../reminders/presentation/reminder_controller.dart';
import '../domain/logging_insight.dart';

/// Vitaly's home dashboard (PROJECT_SPEC.md §10): a greeting, the latest
/// reading, a logging streak, a rule-based logging-pattern nudge, recent
/// readings, a simple 7-day summary, the next reminder, and a featured
/// educational article.
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
    final articles = ref.watch(articlesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vitaly'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        // Unique per screen: the bottom-nav shell keeps every tab (and any
        // route pushed on top) mounted simultaneously, so default hero
        // tags collide across FABs on different screens.
        heroTag: 'dashboard-fab',
        onPressed: () => context.push(AppRoutes.recordBp),
        icon: const Icon(Icons.add),
        label: const Text('Record BP'),
      ),
      body: readingsState.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorView(
          message: friendlyMessage(error),
          onRetry: () => ref.invalidate(readingsStreamProvider),
        ),
        data: (readings) => _DashboardBody(
          displayName: profile?.displayName,
          readings: readings,
          reminders: reminders,
          articles: articles,
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
    required this.articles,
  });

  final String? displayName;
  final List<BloodPressureReading> readings;
  final List<Reminder> reminders;
  final List<Article> articles;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final greeting = displayName == null ? 'Welcome to Vitaly' : 'Welcome, $displayName';
    final nextReminder = NextReminderCalculator.compute(reminders, DateTime.now());
    final now = DateTime.now();
    final streak = computeLoggingStreak(readings, now);
    final insight = computeLoggingInsight(readings, now);

    if (readings.isEmpty) {
      return ListView(
        // Extra bottom padding so the last card can scroll clear of the
        // "Record BP" FAB, which otherwise overlaps and blocks taps on
        // content near the bottom of the list.
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg + AppSpacing.xxl,
        ),
        children: [
          Text(greeting, style: theme.textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.lg),
          Text(
            "You haven't recorded a blood pressure reading yet. "
            'Tap "Record BP" to add your first one.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          _NextReminderCard(occurrence: nextReminder),
          if (articles.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            _EducationCard(article: articles.first),
          ],
        ],
      );
    }

    final latest = readings.first;
    final recent = readings.take(5).toList();
    final weekly = TrendCalculator.compute(readings, TrendPeriod.sevenDays, DateTime.now());

    return ListView(
      // Extra bottom padding so the last card (including "View trends")
      // can scroll clear of the "Record BP" FAB, which otherwise overlaps
      // and blocks taps on content near the bottom of the list.
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg + AppSpacing.xxl,
      ),
      children: [
        Text(greeting, style: theme.textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.lg),
        _LatestReadingCard(reading: latest),
        if (streak > 1) ...[
          const SizedBox(height: AppSpacing.lg),
          _StreakTile(streak: streak),
        ],
        if (insight != null) ...[
          const SizedBox(height: AppSpacing.lg),
          _InsightCard(insight: insight),
        ],
        const SizedBox(height: AppSpacing.lg),
        Text('Recent readings', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Card(
          child: Column(
            children: [
              for (final reading in recent) _RecentReadingTile(reading: reading),
              ListTile(
                title: const Text('View all'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.history),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _WeeklySummaryCard(stats: weekly),
        const SizedBox(height: AppSpacing.lg),
        _NextReminderCard(occurrence: nextReminder),
        if (articles.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          _EducationCard(article: articles.first),
        ],
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
      child: Row(
        children: [
          Icon(Icons.local_fire_department_outlined, color: accents.mintForeground),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'LOGGING STREAK'.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(color: accents.mintForeground),
          ),
          const Spacer(),
          Text(
            '$streak day${streak == 1 ? '' : 's'}',
            style: theme.textTheme.titleMedium?.copyWith(color: accents.mintForeground),
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
          Text(
            'VITALY',
            style: theme.textTheme.labelSmall?.copyWith(color: accents.purpleForeground),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(widget.insight.message, style: TextStyle(color: accents.purpleForeground)),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              FilledButton(
                onPressed: _isSaving ? null : _setReminder,
                child: Text(
                  'Set ${_formatHourMinute(widget.insight.suggestedHour, widget.insight.suggestedMinute)} reminder',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              OutlinedButton(
                onPressed: _isSaving ? null : () => setState(() => _dismissed = true),
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

class _NextReminderCard extends StatelessWidget {
  const _NextReminderCard({required this.occurrence});

  final NextReminderOccurrence? occurrence;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final occ = occurrence;
    return Card(
      child: InkWell(
        onTap: () => context.push(AppRoutes.reminders),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(Icons.notifications_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('NEXT REMINDER', style: theme.textTheme.labelMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      occ == null
                          ? 'No reminders set. Tap to add one.'
                          : '${occ.reminder.label} · ${_formatWhen(occ.when)}',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  String _formatWhen(DateTime when) {
    const weekdayNames = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday',
    };
    final hour = when.hour % 12 == 0 ? 12 : when.hour % 12;
    final period = when.hour < 12 ? 'AM' : 'PM';
    final minute = when.minute.toString().padLeft(2, '0');
    return '${weekdayNames[when.weekday]} at $hour:$minute $period';
  }
}

class _EducationCard extends StatelessWidget {
  const _EducationCard({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: () => context.push(AppRoutes.educationArticlePath(article.id)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.menu_book_outlined, color: theme.colorScheme.primary),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('LEARN', style: theme.textTheme.labelMedium),
                        const SizedBox(height: AppSpacing.xs),
                        Text(article.title, style: theme.textTheme.bodyLarge),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push(AppRoutes.education),
                  child: const Text('Browse all articles'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LatestReadingCard extends StatelessWidget {
  const _LatestReadingCard({required this.reading});

  final BloodPressureReading reading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ts = reading.timestamp;
    final recordedAt =
        '${ts.year}-${ts.month.toString().padLeft(2, '0')}-${ts.day.toString().padLeft(2, '0')} '
        '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}';
    final brightness = theme.brightness;
    final fill = brightness == Brightness.dark ? AppColors.heroFillDark : AppColors.heroFill;

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        onTap: () => context.push(AppRoutes.readingDetailPath(reading.id)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LATEST READING',
                style: theme.textTheme.labelMedium?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${reading.systolic}/${reading.diastolic} mmHg',
                style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white),
              ),
              if (reading.pulse != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${reading.pulse} bpm',
                  style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
                ),
              ],
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Recorded $recordedAt',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentReadingTile extends StatelessWidget {
  const _RecentReadingTile({required this.reading});

  final BloodPressureReading reading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accents = theme.extension<AppAccentColors>() ?? AppAccentColors.light;
    final ts = reading.timestamp;
    final dateLabel =
        '${ts.year}-${ts.month.toString().padLeft(2, '0')}-${ts.day.toString().padLeft(2, '0')} '
        '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}';
    final isMorning = ts.hour < 12;

    return ListTile(
      onTap: () => context.push(AppRoutes.readingDetailPath(reading.id)),
      leading: TagChip(
        label: isMorning ? 'AM' : 'PM',
        background: isMorning ? accents.coralBackground : accents.purpleBackground,
        foreground: isMorning ? accents.coralForeground : accents.purpleForeground,
      ),
      title: Text(
        '${reading.systolic}/${reading.diastolic} mmHg'
        '${reading.pulse != null ? ' · ${reading.pulse} bpm' : ''}',
      ),
      subtitle: Text(dateLabel),
    );
  }
}

class _WeeklySummaryCard extends StatelessWidget {
  const _WeeklySummaryCard({required this.stats});

  final TrendStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('LAST 7 DAYS', style: theme.textTheme.labelMedium),
            const SizedBox(height: AppSpacing.sm),
            if (stats.avgSystolic != null && stats.avgDiastolic != null)
              Text(
                'Average: ${stats.avgSystolic!.round()}/${stats.avgDiastolic!.round()} mmHg '
                'over ${stats.readingCount} reading${stats.readingCount == 1 ? '' : 's'}.',
                style: theme.textTheme.bodyLarge,
              )
            else
              Text(
                'No readings recorded in the last 7 days.',
                style: theme.textTheme.bodyLarge,
              ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push(AppRoutes.trends),
                child: const Text('View trends'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
