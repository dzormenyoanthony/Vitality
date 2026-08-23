import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/errors/failure.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../data/blood_pressure_providers.dart';
import '../data/blood_pressure_reading.dart';
import '../domain/same_time_comparison.dart';
import 'measurement_context_label.dart';

/// Full detail of a single reading, with edit and delete actions
/// (PROJECT_SPEC.md §8, §9). Deletion always requires confirmation.
class ReadingDetailScreen extends ConsumerWidget {
  const ReadingDetailScreen({super.key, required this.readingId});

  final int readingId;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
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
    if (confirmed != true) return;

    try {
      await ref.read(bloodPressureRepositoryProvider).deleteReading(readingId);
      if (context.mounted) context.pop();
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(friendlyMessage(error))));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readingState = ref.watch(readingStreamProvider(readingId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading detail'),
        actions: [
          if (readingState.value != null) ...[
            IconButton(
              tooltip: 'Edit',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push(
                AppRoutes.recordBp,
                extra: readingState.value,
              ),
            ),
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context, ref),
            ),
          ],
        ],
      ),
      body: readingState.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorView(
          message: friendlyMessage(error),
          onRetry: () => ref.invalidate(readingStreamProvider(readingId)),
        ),
        data: (reading) {
          if (reading == null) {
            return const ErrorView(message: 'This reading no longer exists.');
          }
          final allReadings = ref.watch(readingsStreamProvider).value ?? [reading];
          return _ReadingDetailBody(reading: reading, allReadings: allReadings);
        },
      ),
    );
  }
}

class _ReadingDetailBody extends StatelessWidget {
  const _ReadingDetailBody({required this.reading, required this.allReadings});

  final BloodPressureReading reading;
  final List<BloodPressureReading> allReadings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final comparison = sameTimeOfDayReadings(allReadings, reading);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          '${reading.systolic}/${reading.diastolic} mmHg',
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(_formatTimestamp(reading.timestamp), style: theme.textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.lg),
        if (reading.pulse != null) _DetailRow(label: 'Pulse', value: '${reading.pulse} bpm'),
        if (reading.bodyPosition != null)
          _DetailRow(label: 'Body position', value: reading.bodyPosition!.label),
        if (reading.cuffArm != null) _DetailRow(label: 'Cuff arm', value: reading.cuffArm!.label),
        if (reading.measurementContexts.isNotEmpty)
          _DetailRow(
            label: 'Context',
            value: reading.measurementContexts.map((c) => c.label).join(', '),
          ),
        if (reading.notes != null && reading.notes!.isNotEmpty)
          _DetailRow(label: 'Notes', value: reading.notes!),
        if (comparison.length > 1) ...[
          const SizedBox(height: AppSpacing.md),
          _SameTimeOfDayCard(readings: comparison, highlightId: reading.id),
        ],
      ],
    );
  }
}

/// Systolic values for the last few readings sharing this reading's
/// morning/evening bucket — purely a visual comparison of the user's own
/// past entries, no interpretation (PROJECT_SPEC.md §12-14).
class _SameTimeOfDayCard extends StatelessWidget {
  const _SameTimeOfDayCard({required this.readings, required this.highlightId});

  final List<BloodPressureReading> readings;
  final int highlightId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMorning = readings.last.timestamp.hour < 12 ||
        readings.last.measurementContexts.contains(MeasurementContext.morning);
    final maxSystolic = readings.map((r) => r.systolic).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SAME TIME OF DAY, LAST ${readings.length}', style: theme.textTheme.labelMedium),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final r in readings) ...[
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 48,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: r.systolic / maxSystolic,
                            child: Container(
                              decoration: BoxDecoration(
                                color: r.id == highlightId
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text('${r.timestamp.month}/${r.timestamp.day}', style: theme.textTheme.labelSmall),
                    ],
                  ),
                ),
                if (r != readings.last) const SizedBox(width: AppSpacing.xs),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Systolic values, ${isMorning ? 'morning' : 'evening'} readings only.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

String _formatTimestamp(DateTime ts) =>
    '${ts.year}-${ts.month.toString().padLeft(2, '0')}-${ts.day.toString().padLeft(2, '0')} '
    '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}';

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
