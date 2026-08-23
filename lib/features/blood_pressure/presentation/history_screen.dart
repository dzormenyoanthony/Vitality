import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/errors/failure.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../data/blood_pressure_providers.dart';
import '../data/blood_pressure_reading.dart';
import '../domain/history_filter.dart';
import 'measurement_context_label.dart';

/// Chronological list of recorded readings (PROJECT_SPEC.md §8), with a
/// client-side filter and swipe-to-edit/delete on each row. Filtering is
/// display-only over already-fetched readings — no new persistence.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  HistoryFilter _filter = HistoryFilter.all;

  @override
  Widget build(BuildContext context) {
    final readingsState = ref.watch(readingsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      floatingActionButton: FloatingActionButton(
        // Unique per screen: the bottom-nav shell keeps every tab (and any
        // route pushed on top) mounted simultaneously, so default hero
        // tags collide across FABs on different screens.
        heroTag: 'history-fab',
        onPressed: () => context.push(AppRoutes.recordBp),
        tooltip: 'Record BP',
        child: const Icon(Icons.add),
      ),
      body: readingsState.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorView(
          message: friendlyMessage(error),
          onRetry: () => ref.invalidate(readingsStreamProvider),
        ),
        data: (readings) {
          if (readings.isEmpty) {
            return const EmptyView(
              message: 'No readings yet. Tap + to record your first blood pressure reading.',
              icon: Icons.monitor_heart_outlined,
            );
          }
          final filtered = filterReadings(readings, _filter);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    for (final f in HistoryFilter.values)
                      FilterChip(
                        label: Text(f.label),
                        selected: _filter == f,
                        onSelected: (_) => setState(() => _filter = f),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const EmptyView(
                        message: 'No readings match this filter.',
                        icon: Icons.filter_alt_off_outlined,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) =>
                            _ReadingListTile(reading: filtered[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReadingListTile extends ConsumerWidget {
  const _ReadingListTile({required this.reading});

  final BloodPressureReading reading;

  Future<bool> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this reading?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(friendlyMessage(error))));
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final accents = theme.extension<AppAccentColors>() ?? AppAccentColors.light;
    final ts = reading.timestamp;
    final dateLabel =
        '${ts.year}-${ts.month.toString().padLeft(2, '0')}-${ts.day.toString().padLeft(2, '0')} '
        '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}';
    final isMorning = ts.hour < 12;

    return Dismissible(
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
      child: ListTile(
        onTap: () => context.push(AppRoutes.readingDetailPath(reading.id)),
        leading: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Text(
            isMorning ? 'AM' : 'PM',
            style: theme.textTheme.labelSmall?.copyWith(
              color: isMorning ? accents.coralForeground : accents.purpleForeground,
            ),
          ),
        ),
        title: Text(
          '${reading.systolic}/${reading.diastolic} mmHg'
          '${reading.pulse != null ? ' · ${reading.pulse} bpm' : ''}',
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          [dateLabel, ...reading.measurementContexts.map((c) => c.label)].join(' · '),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
