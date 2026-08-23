import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/errors/failure.dart';
import '../data/reminder.dart';
import 'reminder_controller.dart';
import 'weekday_label.dart';

/// Add/edit form for a reminder (PROJECT_SPEC.md §17). Pass
/// [existingReminder] to edit it in place; omit it to create a new one.
class ReminderFormScreen extends ConsumerStatefulWidget {
  const ReminderFormScreen({super.key, this.existingReminder});

  final Reminder? existingReminder;

  @override
  ConsumerState<ReminderFormScreen> createState() => _ReminderFormScreenState();
}

class _ReminderFormScreenState extends ConsumerState<ReminderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late TimeOfDay _time;
  late Set<int> _selectedDays;
  TimeOfDay? _quietHoursStart;
  TimeOfDay? _quietHoursEnd;

  bool get _isEditing => widget.existingReminder != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingReminder;
    _labelController = TextEditingController(text: existing?.label ?? '');
    _time = existing == null
        ? TimeOfDay.now()
        : TimeOfDay(hour: existing.hour, minute: existing.minute);
    _selectedDays = existing?.daysOfWeek.toSet() ?? {};
    _quietHoursStart = existing?.quietHoursStart == null
        ? null
        : TimeOfDay(hour: existing!.quietHoursStart!.$1, minute: existing.quietHoursStart!.$2);
    _quietHoursEnd = existing?.quietHoursEnd == null
        ? null
        : TimeOfDay(hour: existing!.quietHoursEnd!.$1, minute: existing.quietHoursEnd!.$2);
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked == null) return;
    setState(() => _time = picked);
  }

  Future<void> _pickQuietHoursStart() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _quietHoursStart ?? const TimeOfDay(hour: 22, minute: 0),
    );
    if (picked == null) return;
    setState(() => _quietHoursStart = picked);
  }

  Future<void> _pickQuietHoursEnd() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _quietHoursEnd ?? const TimeOfDay(hour: 7, minute: 0),
    );
    if (picked == null) return;
    setState(() => _quietHoursEnd = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDays.isEmpty) {
      setState(() {}); // Trigger a rebuild so the day-selection error shows.
      return;
    }

    await ref
        .read(reminderControllerProvider.notifier)
        .save(
          existingId: widget.existingReminder?.id,
          label: _labelController.text.trim(),
          hour: _time.hour,
          minute: _time.minute,
          daysOfWeek: _selectedDays,
          quietHoursStart: _quietHoursStart == null
              ? null
              : (_quietHoursStart!.hour, _quietHoursStart!.minute),
          quietHoursEnd: _quietHoursEnd == null
              ? null
              : (_quietHoursEnd!.hour, _quietHoursEnd!.minute),
        );

    final state = ref.read(reminderControllerProvider);
    if (!state.hasError && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final saveState = ref.watch(reminderControllerProvider);
    final isSaving = saveState.isLoading;
    final showDaysError = _selectedDays.isEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit reminder' : 'Add reminder')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _labelController,
                  enabled: !isSaving,
                  decoration: const InputDecoration(labelText: 'Label'),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'Enter a label.' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Time'),
                  subtitle: Text(formatTimeOfDay(_time.hour, _time.minute)),
                  trailing: const Icon(Icons.access_time),
                  onTap: isSaving ? null : _pickTime,
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Repeat on', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    for (final day in weekdayShortLabels.entries)
                      FilterChip(
                        label: Text(day.value),
                        selected: _selectedDays.contains(day.key),
                        onSelected: isSaving
                            ? null
                            : (selected) => setState(() {
                                if (selected) {
                                  _selectedDays.add(day.key);
                                } else {
                                  _selectedDays.remove(day.key);
                                }
                              }),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: isSaving ? null : () => setState(() => _selectedDays = {1, 2, 3, 4, 5, 6, 7}),
                    child: const Text('Every day'),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Quiet hours (optional)', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  "If this reminder's time falls in this window, it's delivered "
                  'silently instead of not at all.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('From'),
                        subtitle: Text(
                          _quietHoursStart == null
                              ? 'Not set'
                              : formatTimeOfDay(_quietHoursStart!.hour, _quietHoursStart!.minute),
                        ),
                        onTap: isSaving ? null : _pickQuietHoursStart,
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Until'),
                        subtitle: Text(
                          _quietHoursEnd == null
                              ? 'Not set'
                              : formatTimeOfDay(_quietHoursEnd!.hour, _quietHoursEnd!.minute),
                        ),
                        onTap: isSaving ? null : _pickQuietHoursEnd,
                      ),
                    ),
                  ],
                ),
                if (_quietHoursStart != null || _quietHoursEnd != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: isSaving
                          ? null
                          : () => setState(() {
                              _quietHoursStart = null;
                              _quietHoursEnd = null;
                            }),
                      child: const Text('Clear quiet hours'),
                    ),
                  ),
                if (showDaysError) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      'Select at least one day.',
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ],
                if (saveState.hasError) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      friendlyMessage(saveState.error!),
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: isSaving ? null : _submit,
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isEditing ? 'Save changes' : 'Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
