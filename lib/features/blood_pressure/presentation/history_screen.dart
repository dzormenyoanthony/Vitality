import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/errors/failure.dart';
import '../../../core/i18n/formatters.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../l10n/app_localizations.dart';
import '../data/blood_pressure_providers.dart';
import '../data/blood_pressure_reading.dart';
import '../domain/bp_classification_service.dart';
import '../domain/history_filter.dart';
import 'bp_status_badge.dart';
import 'measurement_context_label.dart';

/// Chronological, day-grouped list of recorded readings (PROJECT_SPEC.md
/// §8), with a client-side filter and swipe-to-edit/delete on each row.
/// Filtering is display-only over already-fetched readings — no new
/// persistence.
///
/// Visual design matches `design_references/History.png`.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  HistoryFilter _filter = HistoryFilter.all;
  bool _newestFirst = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final readingsState = ref.watch(readingsStreamProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        // Unique per screen: the bottom-nav shell keeps every tab (and any
        // route pushed on top) mounted simultaneously, so default hero
        // tags collide across FABs on different screens.
        heroTag: 'history-fab',
        onPressed: () => context.push(AppRoutes.recordBp),
        tooltip: l10n.historyRecordFabTooltip,
        child: const Icon(Icons.add),
      ),
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
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.navHistory,
                      style: theme.textTheme.headlineMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: _newestFirst
                        ? l10n.historySortNewestFirst
                        : l10n.historySortOldestFirst,
                    icon: const Icon(Icons.filter_list),
                    onPressed: () =>
                        setState(() => _newestFirst = !_newestFirst),
                  ),
                  IconButton(
                    tooltip: l10n.commonExport,
                    icon: const Icon(Icons.file_download_outlined),
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.historyExportUnavailable),
                      ),
                    ),
                  ),
                ],
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
                  if (readings.isEmpty) {
                    return EmptyView(
                      message: l10n.historyEmpty,
                      icon: Icons.monitor_heart_outlined,
                    );
                  }
                  final filtered = filterReadings(readings, _filter);
                  final ordered = _newestFirst
                      ? filtered
                      : filtered.reversed.toList();
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          0,
                          AppSpacing.lg,
                          AppSpacing.md,
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final f in HistoryFilter.values)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    right: AppSpacing.sm,
                                  ),
                                  child: _HistoryFilterChip(
                                    filter: f,
                                    selected: _filter == f,
                                    onTap: () => setState(() => _filter = f),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: ordered.isEmpty
                            ? EmptyView(
                                message: l10n.historyEmptyFiltered,
                                icon: Icons.filter_alt_off_outlined,
                              )
                            : _HistoryList(
                                readings: ordered,
                                allReadings: readings,
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _filterLabel(AppLocalizations l10n, HistoryFilter filter) => switch (filter) {
  HistoryFilter.all => l10n.historyFilterAll,
  HistoryFilter.morning => l10n.contextMorning,
  HistoryFilter.evening => l10n.contextEvening,
  HistoryFilter.withNotes => l10n.historyFilterWithNotes,
};

class _HistoryFilterChip extends StatelessWidget {
  const _HistoryFilterChip({
    required this.filter,
    required this.selected,
    required this.onTap,
  });

  final HistoryFilter filter;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final accents = theme.extension<AppAccentColors>() ?? AppAccentColors.light;
    final (background, foreground) = switch (filter) {
      HistoryFilter.all => (accents.mintBackground, accents.mintForeground),
      HistoryFilter.morning => (
        accents.coralBackground,
        accents.coralForeground,
      ),
      HistoryFilter.evening => (
        accents.purpleBackground,
        accents.purpleForeground,
      ),
      HistoryFilter.withNotes => (
        accents.blueBackground,
        accents.blueForeground,
      ),
    };

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: background,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? foreground : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Text(
              _filterLabel(l10n, filter),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: foreground,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Flattens [readings] into day-header + row items and renders them as one
/// scrollable list, ending with a summary line over [allReadings] (the
/// unfiltered set, so the summary stays stable across filter/sort changes).
class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.readings, required this.allReadings});

  final List<BloodPressureReading> readings;
  final List<BloodPressureReading> allReadings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = <Object>[];
    DateTime? lastDay;
    for (final r in readings) {
      final day = DateTime(
        r.timestamp.year,
        r.timestamp.month,
        r.timestamp.day,
      );
      if (lastDay == null || day != lastDay) {
        items.add(day);
        lastDay = day;
      }
      items.add(r);
    }

    final earliest = allReadings
        .map((r) => r.timestamp)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    final summary =
        '${allReadings.length} reading${allReadings.length == 1 ? '' : 's'} recorded '
        'since ${formatShortDate(context, earliest)}';

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == items.length) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              summary,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }
        final item = items[index];
        if (item is DateTime) {
          return _DayHeader(day: item);
        }
        return _ReadingListTile(reading: item as BloodPressureReading);
      },
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final isToday =
        day.year == now.year && day.month == now.month && day.day == now.day;
    final base = formatWeekdayDayMonth(context, day).toUpperCase();
    final label = isToday ? '${l10n.historyDayHeaderTodayPrefix} · $base' : base;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: AppColors.dashboardAccentTeal,
        ),
      ),
    );
  }
}

class _ReadingListTile extends ConsumerWidget {
  const _ReadingListTile({required this.reading});

  final BloodPressureReading reading;

  Future<bool> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.historyDeleteTitle),
        content: Text(l10n.commonCannotBeUndone),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return false;

    try {
      await ref.read(bloodPressureRepositoryProvider).deleteReading(reading.id);
      return true;
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(friendlyMessage(error))));
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final accents = theme.extension<AppAccentColors>() ?? AppAccentColors.light;
    final ts = reading.timestamp;
    final isMorning = ts.hour < 12;
    final timeLabel = formatTime(context, ts);
    final subtitle = _subtitleFor(l10n, reading);

    return Column(
      children: [
        Dismissible(
          key: ValueKey(reading.id),
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            color: accents.mintBackground,
            child: Icon(Icons.edit_outlined, color: accents.mintForeground),
          ),
          secondaryBackground: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            color: accents.coralBackground,
            child: Icon(Icons.delete_outline, color: accents.coralForeground),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              context.push(AppRoutes.recordBp, extra: reading);
              return false; // Editing happens on another screen; keep this row.
            }
            return _confirmDelete(context, ref);
          },
          child: InkWell(
            onTap: () => context.push(AppRoutes.readingDetailPath(reading.id)),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: isMorning
                          ? accents.coralBackground
                          : accents.purpleBackground,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Text(
                      timeLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isMorning
                            ? accents.coralForeground
                            : accents.purpleForeground,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // FittedBox(scaleDown), same as the equivalent
                        // reading value on Dashboard: shrinks the whole
                        // group together at large text scale rather than
                        // truncating either the reading or its unit.
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${reading.systolic}/${reading.diastolic}',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                l10n.unitMmhg,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        BPStatusBadge(
                          classification: BPClassificationService.classify(
                            systolic: reading.systolic,
                            diastolic: reading.diastolic,
                          ),
                          dense: true,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

/// "{pulse} bpm · {position, contexts}" (or "Note added" when there are no
/// position/context tags but the reading does have a note) — purely
/// descriptive metadata, never an interpretation (PROJECT_SPEC.md §12-14).
String? _subtitleFor(AppLocalizations l10n, BloodPressureReading reading) {
  final tags = <String>[
    if (reading.bodyPosition != null) reading.bodyPosition!.label(l10n),
    ...reading.measurementContexts.map((c) => c.label(l10n)),
  ];
  final hasNote = reading.notes != null && reading.notes!.isNotEmpty;

  final parts = <String>[
    if (reading.pulse != null) l10n.historySubtitlePulse(reading.pulse!),
    if (tags.isNotEmpty)
      tags.join(', ')
    else if (hasNote)
      l10n.historySubtitleNoteAdded,
    if (reading.source == ReadingSource.importedReport) l10n.importedReportTag,
  ];
  if (parts.isEmpty) return null;
  return parts.join(' · ');
}
