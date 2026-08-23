import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/errors/failure.dart';
import '../data/blood_pressure_reading.dart';
import '../domain/reading_validator.dart';
import 'measurement_context_label.dart';
import 'record_bp_controller.dart';

/// Add/edit form for a blood-pressure reading (PROJECT_SPEC.md §6).
/// Pass [existingReading] to edit it in place; omit it to record a new one.
class RecordBpScreen extends ConsumerStatefulWidget {
  const RecordBpScreen({super.key, this.existingReading});

  final BloodPressureReading? existingReading;

  @override
  ConsumerState<RecordBpScreen> createState() => _RecordBpScreenState();
}

class _RecordBpScreenState extends ConsumerState<RecordBpScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _systolicController;
  late final TextEditingController _diastolicController;
  late final TextEditingController _pulseController;
  late final TextEditingController _notesController;
  late DateTime _timestamp;
  late Set<MeasurementContext> _contexts;
  BodyPosition? _bodyPosition;
  CuffArm? _cuffArm;

  bool get _isEditing => widget.existingReading != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingReading;
    _systolicController = TextEditingController(
      text: existing == null ? '' : existing.systolic.toString(),
    );
    _diastolicController = TextEditingController(
      text: existing == null ? '' : existing.diastolic.toString(),
    );
    _pulseController = TextEditingController(
      text: existing?.pulse == null ? '' : existing!.pulse.toString(),
    );
    _notesController = TextEditingController(text: existing?.notes ?? '');
    _timestamp = existing?.timestamp ?? DateTime.now();
    _contexts = existing?.measurementContexts.toSet() ?? {};
    _bodyPosition = existing?.bodyPosition;
    _cuffArm = existing?.cuffArm;
  }

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _pulseController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickTimestamp() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _timestamp,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_timestamp),
    );
    if (time == null) return;
    setState(() {
      _timestamp = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final notes = _notesController.text.trim();
    final pulseText = _pulseController.text.trim();

    await ref
        .read(recordBpControllerProvider.notifier)
        .save(
          existingId: widget.existingReading?.id,
          systolic: int.parse(_systolicController.text.trim()),
          diastolic: int.parse(_diastolicController.text.trim()),
          pulse: pulseText.isEmpty ? null : int.parse(pulseText),
          timestamp: _timestamp,
          notes: notes.isEmpty ? null : notes,
          measurementContexts: _contexts.toList(),
          bodyPosition: _bodyPosition,
          cuffArm: _cuffArm,
        );

    final state = ref.read(recordBpControllerProvider);
    if (!state.hasError && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final saveState = ref.watch(recordBpControllerProvider);
    final isSaving = saveState.isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit reading' : 'Record BP')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _systolicController,
                        enabled: !isSaving,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Systolic (mmHg)',
                          suffixText: 'mmHg',
                        ),
                        validator: ReadingValidator.validateSystolic,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: TextFormField(
                        controller: _diastolicController,
                        enabled: !isSaving,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Diastolic (mmHg)',
                          suffixText: 'mmHg',
                        ),
                        validator: ReadingValidator.validateDiastolic,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _pulseController,
                  enabled: !isSaving,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Pulse (optional, bpm)',
                    suffixText: 'bpm',
                  ),
                  validator: ReadingValidator.validatePulse,
                ),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date & time'),
                  subtitle: Text(_formatTimestamp(_timestamp)),
                  trailing: const Icon(Icons.edit_calendar_outlined),
                  onTap: isSaving ? null : _pickTimestamp,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<BodyPosition?>(
                        initialValue: _bodyPosition,
                        decoration: const InputDecoration(labelText: 'Body position (optional)'),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('None')),
                          ...BodyPosition.values.map(
                            (p) => DropdownMenuItem(value: p, child: Text(p.label)),
                          ),
                        ],
                        onChanged: isSaving
                            ? null
                            : (value) => setState(() => _bodyPosition = value),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: DropdownButtonFormField<CuffArm?>(
                        initialValue: _cuffArm,
                        decoration: const InputDecoration(labelText: 'Cuff arm (optional)'),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('None')),
                          ...CuffArm.values.map(
                            (a) => DropdownMenuItem(value: a, child: Text(a.label)),
                          ),
                        ],
                        onChanged: isSaving ? null : (value) => setState(() => _cuffArm = value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Context (optional)', style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final c in MeasurementContext.values)
                      FilterChip(
                        label: Text(c.label),
                        selected: _contexts.contains(c),
                        onSelected: isSaving
                            ? null
                            : (selected) => setState(() {
                                if (selected) {
                                  _contexts.add(c);
                                } else {
                                  _contexts.remove(c);
                                }
                              }),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _notesController,
                  enabled: !isSaving,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (saveState.hasError) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      friendlyMessage(saveState.error!),
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ],
                FilledButton(
                  onPressed: isSaving ? null : _submit,
                  child: isSaving
                      ? Semantics(
                          label: 'Saving',
                          child: const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
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

String _formatTimestamp(DateTime ts) =>
    '${ts.year}-${ts.month.toString().padLeft(2, '0')}-${ts.day.toString().padLeft(2, '0')} '
    '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}';
