import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/errors/failure.dart';
import '../../../core/i18n/formatters.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../data/blood_pressure_reading.dart';
import '../domain/reading_validator.dart';
import 'measurement_context_label.dart';
import 'record_bp_controller.dart';

/// Add/edit form for a blood-pressure reading (PROJECT_SPEC.md §6).
/// Pass [existingReading] to edit it in place; omit it to record a new one.
///
/// Visual design matches `design_references/Add reading.png`.
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final accents = theme.extension<AppAccentColors>() ?? AppAccentColors.light;
    final saveState = ref.watch(recordBpControllerProvider);
    final isSaving = saveState.isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? l10n.recordBpTitleEdit : l10n.recordBpTitleAdd)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.recordSectionRequired,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.dashboardAccentTeal,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: _BigNumberField(
                        controller: _systolicController,
                        enabled: !isSaving,
                        labelText: l10n.recordSystolicLabel,
                        validator: (v) => ReadingValidator.validateSystolic(l10n, v),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _BigNumberField(
                        controller: _diastolicController,
                        enabled: !isSaving,
                        labelText: l10n.recordDiastolicLabel,
                        validator: (v) => ReadingValidator.validateDiastolic(l10n, v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.recordAcceptedRange(
                    ReadingValidator.minSystolic,
                    ReadingValidator.maxSystolic,
                    ReadingValidator.minDiastolic,
                    ReadingValidator.maxDiastolic,
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l10n.recordSectionOptional,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.dashboardAccentTeal,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _BigNumberField(
                        controller: _pulseController,
                        enabled: !isSaving,
                        labelText: l10n.recordPulseLabel,
                        suffixText: l10n.unitBpm,
                        validator: (v) => ReadingValidator.validatePulse(l10n, v),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: DropdownButtonFormField<CuffArm?>(
                        initialValue: _cuffArm,
                        // The dropdown's own outer width already shrinks
                        // to fit (it's in an Expanded above), but without
                        // isExpanded the *selected item* row inside it
                        // doesn't — at large system text sizes its label
                        // overflowed the narrowed field instead of
                        // eliding.
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l10n.recordCuffArmLabel,
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.lg,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                            borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                            borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                            borderSide: const BorderSide(
                              color: AppColors.dashboardAccentTeal,
                              width: 2,
                            ),
                          ),
                        ),
                        items: [
                          DropdownMenuItem(value: null, child: Text(l10n.commonNone)),
                          ...CuffArm.values.map(
                            (a) => DropdownMenuItem(value: a, child: Text(a.label(l10n))),
                          ),
                        ],
                        onChanged: isSaving ? null : (value) => setState(() => _cuffArm = value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final p in BodyPosition.values)
                      _TagChip(
                        label: p.label(l10n),
                        selected: _bodyPosition == p,
                        background: accents.mintBackground,
                        foreground: accents.mintForeground,
                        onTap: isSaving
                            ? null
                            : () => setState(() => _bodyPosition = _bodyPosition == p ? null : p),
                      ),
                    for (final c in MeasurementContext.values)
                      _TagChip(
                        label: c.label(l10n),
                        selected: _contexts.contains(c),
                        background: _contextAccent(c, accents).$1,
                        foreground: _contextAccent(c, accents).$2,
                        onTap: isSaving
                            ? null
                            : () => setState(() {
                                if (_contexts.contains(c)) {
                                  _contexts.remove(c);
                                } else {
                                  _contexts.add(c);
                                }
                              }),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _notesController,
                  enabled: !isSaving,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: l10n.recordNotesHint,
                    contentPadding: const EdgeInsets.all(AppSpacing.md),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      borderSide: const BorderSide(color: AppColors.dashboardAccentTeal, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: Text(formatShortDateTimeWithWeekday(context, _timestamp), style: theme.textTheme.bodyLarge),
                    ),
                    TextButton(
                      onPressed: isSaving ? null : _pickTimestamp,
                      style: TextButton.styleFrom(foregroundColor: AppColors.dashboardAccentTeal),
                      child: Text(l10n.commonChange, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                if (saveState.hasError) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      friendlyMessage(saveState.error!),
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                ],
                FilledButton(
                  onPressed: isSaving ? null : _submit,
                  style: FilledButton.styleFrom(
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    textStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  child: isSaving
                      ? Semantics(
                          label: l10n.commonSaving,
                          child: const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : Text(_isEditing ? l10n.recordSaveChanges : l10n.recordSaveReading),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The oversized bordered number entry used for systolic/diastolic/pulse,
/// matching `design_references/Add reading.png`. [labelText] stays a real
/// `InputDecoration` label (always floated above the box via
/// [FloatingLabelBehavior.always]) rather than a separate sibling widget,
/// so the field's accessible name still includes its unit
/// (PROJECT_SPEC.md §35 — suffixText alone isn't exposed to semantics).
class _BigNumberField extends StatelessWidget {
  const _BigNumberField({
    required this.controller,
    required this.enabled,
    required this.labelText,
    required this.validator,
    this.suffixText,
  });

  final TextEditingController controller;
  final bool enabled;
  final String labelText;
  final String? suffixText;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.number,
      style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        labelText: labelText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: '—',
        suffixText: suffixText,
        suffixStyle: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: const BorderSide(color: AppColors.dashboardAccentTeal, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}

/// A selectable tag chip shared by the body-position (single-select) and
/// context (multi-select) rows — same selected/unselected treatment as the
/// other screens' filter chips (accent-filled when selected, outlined when
/// not).
class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.selected,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? background : theme.colorScheme.surface,
        shape: StadiumBorder(
          side: BorderSide(color: selected ? foreground : theme.colorScheme.outlineVariant),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: selected ? foreground : theme.colorScheme.onSurface,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Groups [MeasurementContext] values into the same 4-accent palette used
/// throughout the app (time-of-day → coral, medication → purple,
/// activity/other → blue) so the merged body-position + context row reads
/// as one consistent tag system, matching
/// `design_references/Add reading.png`.
(Color, Color) _contextAccent(MeasurementContext c, AppAccentColors accents) => switch (c) {
  MeasurementContext.morning ||
  MeasurementContext.evening => (accents.coralBackground, accents.coralForeground),
  MeasurementContext.beforeMedication ||
  MeasurementContext.afterMedication => (accents.purpleBackground, accents.purpleForeground),
  MeasurementContext.afterExercise ||
  MeasurementContext.afterMeal ||
  MeasurementContext.other => (accents.blueBackground, accents.blueForeground),
};

