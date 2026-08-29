import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/errors/failure.dart';
import '../../../core/i18n/formatters.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../blood_pressure/domain/reading_validator.dart';
import '../data/report_providers.dart';
import '../domain/bp_value_extractor.dart';
import '../domain/extracted_reading.dart';
import '../domain/saved_report.dart';
import 'confirm_report_controller.dart';
import 'report_category_label.dart';

/// Arguments passed from [showScanEntrySheet] to [ReviewExtractedScreen].
class ReviewExtractedArgs {
  const ReviewExtractedArgs({
    required this.rawPagePaths,
    required this.documentType,
    required this.source,
  });

  final List<String> rawPagePaths;
  final ReportDocumentType documentType;
  final ReportSource source;
}

/// Runs OCR on the scanned/imported pages, then lets the user review, edit,
/// delete, and confirm the detected readings before anything is saved
/// (PROJECT_SPEC.md "Scan BP Report" §4-7). No value here is written to BP
/// History until the user taps Confirm.
class ReviewExtractedScreen extends ConsumerStatefulWidget {
  const ReviewExtractedScreen({super.key, required this.args});

  final ReviewExtractedArgs args;

  @override
  ConsumerState<ReviewExtractedScreen> createState() => _ReviewExtractedScreenState();
}

class _ReviewExtractedScreenState extends ConsumerState<ReviewExtractedScreen> {
  OcrStatus _ocrStatus = OcrStatus.notProcessed;
  List<ExtractedReading> _readings = [];
  final Set<int> _selectedForHistory = {};
  int _nextId = 0;
  ReportCategory _category = ReportCategory.bpReport;
  final _providerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _runOcr();
  }

  @override
  void dispose() {
    _providerController.dispose();
    super.dispose();
  }

  Future<void> _runOcr() async {
    setState(() => _ocrStatus = OcrStatus.processing);
    try {
      final service = ref.read(textRecognitionServiceProvider);
      final buffer = StringBuffer();
      for (final path in widget.args.rawPagePaths) {
        buffer.writeln(await service.recognizeText(path));
      }
      final readings = BpValueExtractor.extract(buffer.toString());
      final withIds = <ExtractedReading>[];
      for (final r in readings) {
        withIds.add(
          ExtractedReading(
            id: _nextId++,
            systolic: r.systolic,
            diastolic: r.diastolic,
            pulse: r.pulse,
            timestamp: r.timestamp,
          ),
        );
      }
      if (!mounted) return;
      setState(() {
        _readings = withIds;
        _selectedForHistory
          ..clear()
          ..addAll(withIds.map((r) => r.id));
        _ocrStatus = OcrStatus.succeeded;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _ocrStatus = OcrStatus.failed);
    }
  }

  void _deleteReading(int id) {
    setState(() {
      _readings = _readings.where((r) => r.id != id).toList();
      _selectedForHistory.remove(id);
    });
  }

  void _toggleSelected(int id) {
    setState(() {
      if (_selectedForHistory.contains(id)) {
        _selectedForHistory.remove(id);
      } else {
        _selectedForHistory.add(id);
      }
    });
  }

  Future<void> _editReading(ExtractedReading? existing) async {
    final result = await showModalBottomSheet<ExtractedReading>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _EditReadingSheet(existing: existing),
    );
    if (result == null) return;

    setState(() {
      if (existing == null) {
        final withId = ExtractedReading(
          id: _nextId++,
          systolic: result.systolic,
          diastolic: result.diastolic,
          pulse: result.pulse,
          timestamp: result.timestamp,
        );
        _readings = [..._readings, withId];
        _selectedForHistory.add(withId.id);
      } else {
        _readings = _readings
            .map((r) => r.id == existing.id ? result.copyWith(needsReview: r.needsReview) : r)
            .toList();
      }
    });
  }

  Future<void> _confirm() async {
    final l10n = AppLocalizations.of(context);
    final title = l10n.reviewScannedReportTitle(
      formatShortDateTime(context, DateTime.now()),
    );
    await ref
        .read(confirmReportControllerProvider.notifier)
        .confirmAndSave(
          title: title,
          documentType: widget.args.documentType,
          rawPagePaths: widget.args.rawPagePaths,
          ocrStatus: _ocrStatus,
          extractedReadings: _readings,
          confirmedReadings: _readings,
          selectedForHistoryIds: _selectedForHistory,
          source: widget.args.source,
          category: _category,
          provider: _providerController.text.trim().isEmpty
              ? null
              : _providerController.text.trim(),
        );

    final state = ref.read(confirmReportControllerProvider);
    if (state.hasError || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _selectedForHistory.isEmpty
              ? l10n.reviewReportSaved
              : l10n.reviewReportSavedWithReadings(_selectedForHistory.length),
        ),
      ),
    );
    context.go(AppRoutes.savedReports);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final saveState = ref.watch(confirmReportControllerProvider);
    final isSaving = saveState.isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reviewTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildBody(theme, isSaving)),
            if (saveState.hasError)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  friendlyMessage(saveState.error!),
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isSaving || _ocrStatus == OcrStatus.processing ? null : _confirm,
                  style: FilledButton.styleFrom(
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _ocrStatus == OcrStatus.failed
                              ? l10n.reviewSaveWithoutInfo
                              : l10n.reviewConfirmAndSave,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Lets the user file this document into a category and (optionally)
  /// note who it's from, matching `design_references/My document
  /// locker.png`'s category filters and per-file provider label.
  Widget _buildDetailsSection(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.reviewDocumentDetails, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<ReportCategory>(
              initialValue: _category,
              decoration: InputDecoration(labelText: l10n.savedReportsFieldCategory),
              items: [
                for (final category in ReportCategory.values)
                  DropdownMenuItem(value: category, child: Text(category.label(l10n))),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _providerController,
              decoration: InputDecoration(
                labelText: l10n.savedReportsFieldSource,
                hintText: l10n.reviewSourceHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme, bool isSaving) {
    final l10n = AppLocalizations.of(context);
    if (_ocrStatus == OcrStatus.processing) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppSpacing.md),
            Text(l10n.reviewProcessing),
          ],
        ),
      );
    }

    if (_ocrStatus == OcrStatus.failed) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_outlined, size: 40, color: theme.colorScheme.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.reviewOcrFailedTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.reviewOcrFailedBody,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton(
              onPressed: isSaving ? null : _runOcr,
              child: Text(l10n.commonRetry),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: isSaving ? null : () => context.pop(),
              child: Text(l10n.reviewScanAgain),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildDetailsSection(theme),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _buildDetailsSection(theme),
        const SizedBox(height: AppSpacing.lg),
        Text(
          _readings.isEmpty ? l10n.reviewNoReadings : l10n.reviewInstructions,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final reading in _readings)
          _ExtractedReadingCard(
            reading: reading,
            selected: _selectedForHistory.contains(reading.id),
            onToggleSelected: () => _toggleSelected(reading.id),
            onEdit: () => _editReading(reading),
            onDelete: () => _deleteReading(reading.id),
          ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: () => _editReading(null),
          icon: const Icon(Icons.add),
          label: Text(l10n.reviewAddMissing),
        ),
      ],
    );
  }
}

class _ExtractedReadingCard extends StatelessWidget {
  const _ExtractedReadingCard({
    required this.reading,
    required this.selected,
    required this.onToggleSelected,
    required this.onEdit,
    required this.onDelete,
  });

  final ExtractedReading reading;
  final bool selected;
  final VoidCallback onToggleSelected;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: selected,
              onChanged: (_) => onToggleSelected(),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: [
                      Text(
                        l10n.reviewReadingValue(reading.systolic, reading.diastolic),
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (reading.needsReview) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.remindersWarningBackground,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: Text(
                            l10n.reviewNeedsReview,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.remindersWarningDot,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      if (reading.pulse != null) l10n.dashboardPulseSummary(reading.pulse!),
                      reading.timestamp == null
                          ? l10n.reviewNoDate
                          : formatShortDateTime(context, reading.timestamp!),
                    ].join(' · '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: l10n.commonEdit,
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: l10n.commonDelete,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _EditReadingSheet extends StatefulWidget {
  const _EditReadingSheet({this.existing});

  final ExtractedReading? existing;

  @override
  State<_EditReadingSheet> createState() => _EditReadingSheetState();
}

class _EditReadingSheetState extends State<_EditReadingSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _systolicController;
  late final TextEditingController _diastolicController;
  late final TextEditingController _pulseController;
  late DateTime _timestamp;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _systolicController = TextEditingController(text: existing?.systolic.toString() ?? '');
    _diastolicController = TextEditingController(text: existing?.diastolic.toString() ?? '');
    _pulseController = TextEditingController(text: existing?.pulse?.toString() ?? '');
    _timestamp = existing?.timestamp ?? DateTime.now();
  }

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
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

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final pulseText = _pulseController.text.trim();
    Navigator.of(context).pop(
      ExtractedReading(
        id: widget.existing?.id ?? 0,
        systolic: int.parse(_systolicController.text.trim()),
        diastolic: int.parse(_diastolicController.text.trim()),
        pulse: pulseText.isEmpty ? null : int.parse(pulseText),
        timestamp: _timestamp,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existing == null ? l10n.recordBpTitleAdd : l10n.recordBpTitleEdit,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _systolicController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.recordSystolicLabel),
                    validator: ReadingValidator.validateSystolic,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextFormField(
                    controller: _diastolicController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.recordDiastolicLabel),
                    validator: ReadingValidator.validateDiastolic,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _pulseController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.recordPulseLabel),
              validator: ReadingValidator.validatePulse,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(child: Text(formatShortDateTime(context, _timestamp))),
                TextButton(onPressed: _pickDate, child: Text(l10n.reviewChangeDate)),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(onPressed: _save, child: Text(l10n.commonSave)),
          ],
        ),
      ),
    );
  }
}

