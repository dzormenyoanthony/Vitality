import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/errors/failure.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../data/blood_pressure_providers.dart';
import '../data/blood_pressure_reading.dart';
import 'measurement_context_label.dart';

/// Chronological list of recorded readings (PROJECT_SPEC.md §8).
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readingsState = ref.watch(readingsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      floatingActionButton: FloatingActionButton(
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
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            itemCount: readings.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) => _ReadingListTile(reading: readings[index]),
          );
        },
      ),
    );
  }
}

class _ReadingListTile extends StatelessWidget {
  const _ReadingListTile({required this.reading});

  final BloodPressureReading reading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ts = reading.timestamp;
    final dateLabel =
        '${ts.year}-${ts.month.toString().padLeft(2, '0')}-${ts.day.toString().padLeft(2, '0')} '
        '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}';

    return ListTile(
      onTap: () => context.push(AppRoutes.readingDetailPath(reading.id)),
      title: Text(
        '${reading.systolic}/${reading.diastolic} mmHg'
        '${reading.pulse != null ? ' · ${reading.pulse} bpm' : ''}',
        style: theme.textTheme.titleMedium,
      ),
      subtitle: Text(
        [dateLabel, if (reading.measurementContext != null) reading.measurementContext!.label]
            .join(' · '),
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
