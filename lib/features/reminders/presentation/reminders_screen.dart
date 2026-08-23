import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/errors/failure.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../data/reminder.dart';
import '../data/reminder_providers.dart';
import 'reminder_controller.dart';
import 'weekday_label.dart';

/// List of measurement reminders (PROJECT_SPEC.md §17).
class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersState = ref.watch(remindersStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      floatingActionButton: FloatingActionButton(
        // Unique per screen: the bottom-nav shell keeps every tab (and any
        // route pushed on top) mounted simultaneously, so default hero
        // tags collide across FABs on different screens.
        heroTag: 'reminders-fab',
        onPressed: () => context.push(AppRoutes.reminderForm),
        tooltip: 'Add reminder',
        child: const Icon(Icons.add),
      ),
      body: remindersState.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorView(
          message: friendlyMessage(error),
          onRetry: () => ref.invalidate(remindersStreamProvider),
        ),
        data: (reminders) {
          if (reminders.isEmpty) {
            return const EmptyView(
              message: 'No reminders yet. Tap + to add one.',
              icon: Icons.notifications_none,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            itemCount: reminders.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) => _ReminderTile(reminder: reminders[index]),
          );
        },
      ),
    );
  }
}

class _ReminderTile extends ConsumerWidget {
  const _ReminderTile({required this.reminder});

  final Reminder reminder;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this reminder?'),
        content: Text('"${reminder.label}" will no longer remind you.'),
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
    await ref.read(reminderControllerProvider.notifier).delete(reminder.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      onTap: () => context.push(AppRoutes.reminderForm, extra: reminder),
      title: Text(reminder.label),
      subtitle: Text(
        [
          '${formatTimeOfDay(reminder.hour, reminder.minute)} · ${daysSummary(reminder.daysOfWeek)}',
          if (reminder.quietHoursStart != null && reminder.quietHoursEnd != null)
            'silenced ${formatTimeOfDay(reminder.quietHoursStart!.$1, reminder.quietHoursStart!.$2)}'
                '–${formatTimeOfDay(reminder.quietHoursEnd!.$1, reminder.quietHoursEnd!.$2)}',
        ].join(' · '),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: reminder.enabled,
            onChanged: (value) =>
                ref.read(reminderControllerProvider.notifier).setEnabled(reminder.id, value),
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
    );
  }
}
