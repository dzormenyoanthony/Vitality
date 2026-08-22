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
          return _ReadingDetailBody(reading: reading);
        },
      ),
    );
  }
}

class _ReadingDetailBody extends StatelessWidget {
  const _ReadingDetailBody({required this.reading});

  final BloodPressureReading reading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          '${reading.systolic}/${reading.diastolic} mmHg',
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(reading.timestamp.toString(), style: theme.textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.lg),
        if (reading.pulse != null) _DetailRow(label: 'Pulse', value: '${reading.pulse} bpm'),
        if (reading.measurementContext != null)
          _DetailRow(label: 'Context', value: reading.measurementContext!.label),
        if (reading.notes != null && reading.notes!.isNotEmpty)
          _DetailRow(label: 'Notes', value: reading.notes!),
      ],
    );
  }
}

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
