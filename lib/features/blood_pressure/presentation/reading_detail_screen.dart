import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/errors/failure.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../data/blood_pressure_providers.dart';
import '../data/blood_pressure_reading.dart';
import '../domain/bp_classification_service.dart';
import '../domain/same_time_comparison.dart';
import 'bp_status_badge.dart';
import 'measurement_context_label.dart';

const _weekdayNames = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
]; // ignore: prefer_const_declarations

const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
]; // ignore: prefer_const_declarations

const _shortMonthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
]; // ignore: prefer_const_declarations

/// Full detail of a single reading, with edit and delete actions
/// (PROJECT_SPEC.md §8, §9). Deletion always requires confirmation.
///
/// Visual design matches `design_references/Reading.png`.
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
        title: const Text('Reading'),
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
    final classification = BPClassificationService.classify(
      systolic: reading.systolic,
      diastolic: reading.diastolic,
    );

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          _formatFullDate(reading.timestamp),
          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.sm),
        _BigReading(reading: reading),
        const SizedBox(height: AppSpacing.sm),
        BPStatusBadge(
          classification: classification,
          onExplain: () => showBpExplanationSheet(context, classification),
        ),
        const SizedBox(height: AppSpacing.lg),
        const Divider(height: 1),
        if (reading.pulse != null) ...[
          _DetailRow(label: 'Pulse', value: '${reading.pulse} bpm'),
          const Divider(height: 1),
        ],
        if (reading.bodyPosition != null) ...[
          _DetailRow(label: 'Body position', value: reading.bodyPosition!.label),
          const Divider(height: 1),
        ],
        if (reading.cuffArm != null) ...[
          _DetailRow(label: 'Cuff arm', value: reading.cuffArm!.label),
          const Divider(height: 1),
        ],
        if (reading.measurementContexts.isNotEmpty) ...[
          _DetailRow(
            label: 'Context',
            value: reading.measurementContexts.map((c) => c.label).join(', '),
          ),
          const Divider(height: 1),
        ],
        _DetailRow(
          label: 'Entered',
          value: reading.source == ReadingSource.importedReport ? 'Imported Report' : 'Manually',
        ),
        const Divider(height: 1),
        if (reading.notes != null && reading.notes!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            'NOTE',
            style: theme.textTheme.labelMedium?.copyWith(color: AppColors.dashboardAccentTeal),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(reading.notes!, style: theme.textTheme.bodyLarge),
        ],
        if (comparison.length > 1) ...[
          const SizedBox(height: AppSpacing.lg),
          _SameTimeOfDayCard(readings: comparison, highlightId: reading.id),
        ],
      ],
    );
  }
}

/// The large systolic/diastolic readout at the top of the screen, matching
/// the same "big bold numbers, muted slash and unit" treatment used for
/// the Dashboard's latest-reading card.
class _BigReading extends StatelessWidget {
  const _BigReading({required this.reading});

  final BloodPressureReading reading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${reading.systolic}',
            style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              '/',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '${reading.diastolic}',
            style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              'mmHg',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatFullDate(DateTime ts) {
  final weekday = _weekdayNames[ts.weekday - 1];
  final month = _monthNames[ts.month - 1];
  final hh = ts.hour.toString().padLeft(2, '0');
  final mm = ts.minute.toString().padLeft(2, '0');
  return '$weekday ${ts.day} $month ${ts.year} · $hh:$mm';
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
          Text(
            'SAME TIME OF DAY, LAST ${readings.length}',
            style: theme.textTheme.labelMedium?.copyWith(color: AppColors.dashboardAccentTeal),
          ),
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
                                    ? AppColors.dashboardAccentTeal
                                    : AppColors.readingBarFill,
                                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(_shortDateLabel(r.timestamp), style: theme.textTheme.labelSmall),
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

String _shortDateLabel(DateTime ts) => '${ts.day} ${_shortMonthNames[ts.month - 1]}';

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: AppSpacing.md),
          // Expanded (not Spacer + Flexible, which split the remaining
          // width 50/50 and squeezed longer values into an unnecessary
          // second line) so every value gets the full remaining width and
          // right-aligns flush against the same edge across every row.
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
