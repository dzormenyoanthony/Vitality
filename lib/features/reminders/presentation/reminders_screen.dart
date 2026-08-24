import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/errors/failure.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../data/reminder.dart';
import '../data/reminder_providers.dart';
import 'reminder_controller.dart';
import 'weekday_label.dart';

const _dayInitials = {1: 'M', 2: 'T', 3: 'W', 4: 'T', 5: 'F', 6: 'S', 7: 'S'};

String _twoDigitTime(int hour, int minute) =>
    '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

/// List of measurement reminders (PROJECT_SPEC.md §17).
///
/// Visual design matches `design_references/Reminders.png`: a plain
/// header (no AppBar — the system back gesture/button returns, as on any
/// Android screen), rows with a large 24-hour time and a delivery-status
/// dot, an inline "new reminder" quick-add card, and a live
/// system-notifications-off warning.
class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> with WidgetsBindingObserver {
  bool _showAddForm = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The user may have just come back from the OS notification settings
    // screen (reached via the warning banner below) — re-check.
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(notificationsEnabledProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remindersState = ref.watch(remindersStreamProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);

    return Scaffold(
      body: SafeArea(
        child: remindersState.when(
          loading: () => const LoadingIndicator(),
          error: (error, _) => ErrorView(
            message: friendlyMessage(error),
            onRetry: () => ref.invalidate(remindersStreamProvider),
          ),
          data: (reminders) => ListView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reminders', style: theme.textTheme.headlineMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Reminders prompt you to measure. Vitaly never asks you to '
                      'change medication or treatment.',
                      style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.onboardingBody),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              if (reminders.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    'No reminders yet.',
                    style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.onboardingBody),
                  ),
                )
              else
                for (final reminder in reminders) ...[
                  _ReminderRow(reminder: reminder),
                  const Divider(height: 1),
                ],
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                child: TextButton.icon(
                  onPressed: () => setState(() => _showAddForm = !_showAddForm),
                  icon: const Icon(Icons.add),
                  label: const Text('Add reminder'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.dashboardAccentTeal),
                ),
              ),
              if (_showAddForm)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  child: _NewReminderCard(onDone: () => setState(() => _showAddForm = false)),
                ),
              notificationsEnabled.when(
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
                data: (enabled) => enabled
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.sm,
                          AppSpacing.lg,
                          AppSpacing.sm,
                        ),
                        child: _NotificationsOffBanner(),
                      ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'Notifications are delivered by Android. Silent hours are '
                  'respected. Status colours describe delivery only, never '
                  'your readings.',
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.onboardingBody),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationsOffBanner extends ConsumerWidget {
  const _NotificationsOffBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.remindersWarningBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.remindersWarningDot,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.onboardingBody),
                children: [
                  const TextSpan(text: 'System notifications for Vitaly are switched off. '),
                  TextSpan(
                    text: 'Open Android settings',
                    style: const TextStyle(
                      color: AppColors.dashboardAccentTeal,
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => ref.read(notificationSchedulerProvider).openNotificationSettings(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderRow extends ConsumerWidget {
  const _ReminderRow({required this.reminder});

  final Reminder reminder;

  Future<bool> _confirmDelete(BuildContext context, WidgetRef ref) async {
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
    if (confirmed != true) return false;
    await ref.read(reminderControllerProvider.notifier).delete(reminder.id);
    return true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final accents = theme.extension<AppAccentColors>() ?? AppAccentColors.light;
    final enabled = reminder.enabled;
    final hasQuietHours = reminder.quietHoursStart != null && reminder.quietHoursEnd != null;

    final String statusText;
    Color? dotColor;
    if (!enabled) {
      statusText = '${daysSummary(reminder.daysOfWeek)} · Off';
    } else {
      final timeOfDayLabel = reminder.hour < 12 ? 'Morning' : 'Evening';
      if (hasQuietHours) {
        final start = reminder.quietHoursStart!;
        final end = reminder.quietHoursEnd!;
        statusText =
            '${daysSummary(reminder.daysOfWeek)} · $timeOfDayLabel · '
            'silenced ${_twoDigitTime(start.$1, start.$2)}–${_twoDigitTime(end.$1, end.$2)}';
        dotColor = AppColors.remindersSilencedDot;
      } else {
        statusText = '${daysSummary(reminder.daysOfWeek)} · $timeOfDayLabel · delivering';
        dotColor = AppColors.remindersDeliveringDot;
      }
    }

    return Dismissible(
      key: ValueKey(reminder.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        color: accents.coralBackground,
        child: Icon(Icons.delete_outline, color: accents.coralForeground),
      ),
      confirmDismiss: (_) => _confirmDelete(context, ref),
      child: InkWell(
        onTap: () => context.push(AppRoutes.reminderForm, extra: reminder),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _twoDigitTime(reminder.hour, reminder.minute),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: enabled ? AppColors.onboardingHeadline : AppColors.onboardingFieldBorder,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        if (dotColor != null) ...[
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                        ],
                        Flexible(
                          child: Text(
                            statusText,
                            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.onboardingBody),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Switch(
                value: enabled,
                onChanged: (value) =>
                    ref.read(reminderControllerProvider.notifier).setEnabled(reminder.id, value),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Inline quick-add card matching the reference's "NEW REMINDER" panel —
/// time + AM/PM + repeat days only. Editing an existing reminder (with
/// its extra quiet-hours fields) still goes through the full
/// `ReminderFormScreen`, reached by tapping a row above.
class _NewReminderCard extends ConsumerStatefulWidget {
  const _NewReminderCard({required this.onDone});

  final VoidCallback onDone;

  @override
  ConsumerState<_NewReminderCard> createState() => _NewReminderCardState();
}

class _NewReminderCardState extends ConsumerState<_NewReminderCard> {
  TimeOfDay _time = TimeOfDay.now();
  final Set<int> _selectedDays = {};
  bool _isSaving = false;

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked == null) return;
    setState(() => _time = picked);
  }

  void _setPeriod(DayPeriod period) {
    if (_time.period == period) return;
    final newHour = period == DayPeriod.am ? _time.hour - 12 : _time.hour + 12;
    setState(() => _time = TimeOfDay(hour: newHour % 24, minute: _time.minute));
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await ref
        .read(reminderControllerProvider.notifier)
        .save(
          label: _time.hour < 12 ? 'Morning reading' : 'Evening reading',
          hour: _time.hour,
          minute: _time.minute,
          daysOfWeek: _selectedDays,
        );
    if (!mounted) return;
    final state = ref.read(reminderControllerProvider);
    setState(() => _isSaving = false);
    if (!state.hasError) widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const accent = AppColors.dashboardAccentTeal;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.onboardingFieldBorder.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NEW REMINDER',
            style: theme.textTheme.labelMedium?.copyWith(color: accent),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                onTap: _isSaving ? null : _pickTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    border: Border.all(color: accent, width: 2),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Text(
                    '${(_time.hourOfPeriod == 0 ? 12 : _time.hourOfPeriod).toString().padLeft(2, '0')} : '
                    '${_time.minute.toString().padLeft(2, '0')}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onboardingHeadline,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                children: [
                  _PeriodPill(
                    label: 'AM',
                    selected: _time.period == DayPeriod.am,
                    onTap: _isSaving ? null : () => _setPeriod(DayPeriod.am),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _PeriodPill(
                    label: 'PM',
                    selected: _time.period == DayPeriod.pm,
                    onTap: _isSaving ? null : () => _setPeriod(DayPeriod.pm),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text('REPEAT', style: theme.textTheme.labelMedium?.copyWith(color: accent)),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              for (final day in _dayInitials.entries) ...[
                _DayCircle(
                  label: day.value,
                  selected: _selectedDays.contains(day.key),
                  onTap: _isSaving
                      ? null
                      : () => setState(() {
                          if (_selectedDays.contains(day.key)) {
                            _selectedDays.remove(day.key);
                          } else {
                            _selectedDays.add(day.key);
                          }
                        }),
                ),
                if (day.key != 7) const SizedBox(width: AppSpacing.xs),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: _isSaving ? null : widget.onDone,
                  style: TextButton.styleFrom(foregroundColor: accent),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: _isSaving || _selectedDays.isEmpty ? null : _save,
                  style: TextButton.styleFrom(foregroundColor: accent),
                  child: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodPill extends StatelessWidget {
  const _PeriodPill({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      onTap: onTap,
      child: Container(
        width: 56,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.dashboardBadgeBackground : null,
          border: Border.all(
            color: selected ? AppColors.dashboardAccentTeal : AppColors.onboardingFieldBorder,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Text(label, style: TextStyle(color: AppColors.onboardingHeadline)),
      ),
    );
  }
}

class _DayCircle extends StatelessWidget {
  const _DayCircle({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? AppColors.dashboardAccentTeal : null,
          border: selected ? null : Border.all(color: AppColors.onboardingFieldBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.onboardingBody,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
