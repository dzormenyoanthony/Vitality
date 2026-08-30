import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/errors/failure.dart';
import '../../../core/i18n/formatters.dart';
import '../../../core/paywall/paywall_placements.dart';
import '../../../core/paywall/paywall_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../l10n/app_localizations.dart';
import '../../blood_pressure/data/blood_pressure_providers.dart';
import '../../blood_pressure/data/blood_pressure_reading.dart';
import '../../blood_pressure/domain/trend_calculator.dart';
import '../../blood_pressure/presentation/trend_pdf_export.dart';
import '../../reports/data/report_providers.dart';
import '../../reports/domain/saved_report.dart';
import '../../reports/presentation/saved_reports_screen.dart' show formatFileSize;
import '../data/data_export_providers.dart';
import '../domain/bp_readings_csv.dart';
import '../domain/export_options.dart';
import 'data_export_share.dart';

/// The "Export data" screen (`design_references/Export Data screen.png`).
///
/// Turns PROJECT_SPEC.md §28's one-tap export into a chooser: a date
/// range, one of three formats (the §11 Trends PDF, a standalone readings
/// CSV, or §28's full CSV+documents ZIP), and toggles that drop the
/// optional CSV columns / the archive's attached documents. Everything is
/// built on-device and handed straight to the system share sheet — no
/// copy is kept (§25).
class ExportDataScreen extends ConsumerStatefulWidget {
  const ExportDataScreen({super.key});

  @override
  ConsumerState<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends ConsumerState<ExportDataScreen> {
  ExportOptions _options = const ExportOptions();
  bool _isExporting = false;

  List<BloodPressureReading> _inRange(List<BloodPressureReading> all) {
    final start = _options.dateRange.startFrom(DateTime.now());
    final filtered = all
        .where((r) => start == null || !r.timestamp.isBefore(start))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return filtered;
  }

  String _stamp(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Gates the "Export Report/Data" premium action (superwall_paywall.md)
  /// behind the `export_report_data` placement before any export file is
  /// generated.
  Future<void> _export(List<BloodPressureReading> readings) {
    if (readings.isEmpty) return Future.value();
    return ref.read(paywallServiceProvider).gateFeature(
      placement: PaywallPlacements.exportReportData,
      onAccessGranted: () => _exportImpl(readings),
    );
  }

  Future<void> _exportImpl(List<BloodPressureReading> readings) async {
    if (!mounted) return;
    setState(() => _isExporting = true);
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final today = _stamp(DateTime.now());
    try {
      switch (_options.format) {
        case ExportFormat.pdfSummary:
          final stats = TrendCalculator.compute(
            readings,
            TrendPeriod.all,
            DateTime.now(),
          );
          final bytes = await buildTrendSummaryPdf(
            l10n,
            stats,
            includePulse: _options.includePulse,
          );
          if (!mounted) return;
          await shareExportFile(
            bytes: bytes,
            filename: 'vitaly_trend_summary_$today.pdf',
            mimeType: 'application/pdf',
          );

        case ExportFormat.csvSpreadsheet:
          final csv = buildBpReadingsCsv(
            readings,
            includePulse: _options.includePulse,
            includeNotesAndTags: _options.includeNotesAndTags,
          );
          if (!mounted) return;
          await shareExportFile(
            bytes: Uint8List.fromList(utf8.encode(csv)),
            filename: 'vitaly_bp_readings_$today.csv',
            mimeType: 'text/csv',
          );

        case ExportFormat.fullArchive:
          final result = await ref.read(dataExportServiceProvider).buildArchive(
            readings: readings,
            includeReportFiles: _options.includeAttachedDocuments,
            includePulse: _options.includePulse,
            includeNotesAndTags: _options.includeNotesAndTags,
          );
          if (!mounted) return;
          if (result.hasMissingFiles) {
            final proceed = await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: Text(l10n.settingsExportMissingTitle),
                content: Text(
                  l10n.settingsExportMissingBody(
                    result.missingReportFiles.join('\n'),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: Text(l10n.commonCancel),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: Text(l10n.commonContinue),
                  ),
                ],
              ),
            );
            if (proceed != true || !mounted) return;
          }
          await shareDataExport(result);
      }
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.settingsExportFailed)));
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final readingsState = ref.watch(readingsStreamProvider);
    final reports = ref.watch(savedReportsStreamProvider).value ?? const [];

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: readingsState.when(
          loading: () => const LoadingIndicator(),
          error: (error, _) => ErrorView(message: friendlyMessage(error)),
          data: (allReadings) {
            final readings = _inRange(allReadings);
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sm,
                    AppSpacing.xs,
                    AppSpacing.lg,
                    0,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        tooltip: l10n.commonBack,
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go(AppRoutes.settings);
                          }
                        },
                      ),
                      Text(
                        l10n.exportDataTitle,
                        style: theme.textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    children: [
                      _HeroCard(readings: readings, reports: reports),
                      const SizedBox(height: AppSpacing.lg),
                      _SectionLabel(l10n.exportSectionDateRange),
                      const SizedBox(height: AppSpacing.sm),
                      _DateRangeChips(
                        selected: _options.dateRange,
                        onSelected: (r) => setState(
                          () => _options = _options.copyWith(dateRange: r),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _SectionLabel(l10n.exportSectionFormat),
                      const SizedBox(height: AppSpacing.sm),
                      _FormatOptionCard(
                        badge: l10n.exportBadgePdf,
                        title: l10n.exportFormatPdfTitle,
                        subtitle: l10n.exportFormatPdfSubtitle,
                        selected: _options.format == ExportFormat.pdfSummary,
                        onTap: () => setState(
                          () => _options = _options.copyWith(
                            format: ExportFormat.pdfSummary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _FormatOptionCard(
                        badge: l10n.exportBadgeCsv,
                        title: l10n.exportFormatCsvTitle,
                        subtitle: l10n.exportFormatCsvSubtitle,
                        selected:
                            _options.format == ExportFormat.csvSpreadsheet,
                        onTap: () => setState(
                          () => _options = _options.copyWith(
                            format: ExportFormat.csvSpreadsheet,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _FormatOptionCard(
                        badge: l10n.exportBadgeZip,
                        title: l10n.exportFormatArchiveTitle,
                        subtitle: l10n.exportFormatArchiveSubtitle,
                        selected: _options.format == ExportFormat.fullArchive,
                        onTap: () => setState(
                          () => _options = _options.copyWith(
                            format: ExportFormat.fullArchive,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _TogglesCard(
                        options: _options,
                        onChanged: (o) => setState(() => _options = o),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _PrivacyNote(),
                    ],
                  ),
                ),
                _ExportButton(
                  count: readings.length,
                  busy: _isExporting,
                  onPressed: readings.isEmpty || _isExporting
                      ? null
                      : () => _export(readings),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.labelSmall?.copyWith(
      color: AppColors.dashboardAccentTeal,
    ),
  );
}

/// Dark-teal "ready to export" summary, matching the document-locker hero's
/// always-branded gradient treatment.
class _HeroCard extends ConsumerWidget {
  const _HeroCard({required this.readings, required this.reports});

  final List<BloodPressureReading> readings;
  final List<SavedReport> reports;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final storage = ref.read(reportDocumentStorageProvider);
    final pagePaths = [for (final r in reports) ...r.localPagePaths];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.dashboardAccentTeal, AppColors.heroFill],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.exportReadyEyebrow,
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.documentLockerEyebrow,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (readings.isEmpty)
            Text(
              l10n.exportEmptyRange,
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
            )
          else
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${readings.length}',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    l10n.exportReadySpan(
                      l10n.exportReadingsWord(readings.length),
                      '${formatDayMonth(context, readings.first.timestamp)} – '
                          '${formatDayMonth(context, readings.last.timestamp)}',
                    ),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.documentLockerMetaText,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          FutureBuilder<int>(
            future: storage.totalSizeBytes(pagePaths),
            builder: (context, snapshot) => Text(
              l10n.exportIncludesDocuments(
                pagePaths.length,
                formatFileSize(snapshot.data ?? 0),
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.documentLockerMetaText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateRangeChips extends StatelessWidget {
  const _DateRangeChips({required this.selected, required this.onSelected});

  final ExportDateRange selected;
  final ValueChanged<ExportDateRange> onSelected;

  String _label(AppLocalizations l10n, ExportDateRange range) => switch (range) {
    ExportDateRange.last30Days => l10n.exportRangeLast30Days,
    ExportDateRange.last90Days => l10n.exportRangeLast90Days,
    ExportDateRange.thisYear => l10n.exportRangeThisYear,
    ExportDateRange.allTime => l10n.exportRangeAllTime,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final range in ExportDateRange.values)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: _Chip(
                label: _label(l10n, range),
                selected: range == selected,
                onTap: () => onSelected(range),
              ),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? theme.colorScheme.inverseSurface : theme.colorScheme.surface,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? Colors.transparent : theme.colorScheme.outlineVariant,
          ),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: selected
                    ? theme.colorScheme.onInverseSurface
                    : theme.colorScheme.onSurface,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormatOptionCard extends StatelessWidget {
  const _FormatOptionCard({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String badge;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accents = theme.extension<AppAccentColors>() ?? AppAccentColors.light;

    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: selected,
      button: true,
      child: Material(
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: BorderSide(
            color: selected
                ? AppColors.dashboardAccentTeal
                : theme.colorScheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accents.mintBackground,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.insert_drive_file_outlined,
                        size: 16,
                        color: accents.mintForeground,
                      ),
                      Text(
                        badge,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: accents.mintForeground,
                          fontSize: 8,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selected
                      ? AppColors.dashboardAccentTeal
                      : theme.colorScheme.outlineVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TogglesCard extends StatelessWidget {
  const _TogglesCard({required this.options, required this.onChanged});

  final ExportOptions options;
  final ValueChanged<ExportOptions> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Column(
        children: [
          _ToggleRow(
            label: l10n.exportToggleNotes,
            value: options.includeNotesAndTags,
            onChanged: (v) =>
                onChanged(options.copyWith(includeNotesAndTags: v)),
          ),
          const Divider(height: 1),
          _ToggleRow(
            label: l10n.exportToggleDocuments,
            value: options.includeAttachedDocuments,
            onChanged: (v) =>
                onChanged(options.copyWith(includeAttachedDocuments: v)),
          ),
          const Divider(height: 1),
          _ToggleRow(
            label: l10n.exportTogglePulse,
            value: options.includePulse,
            onChanged: (v) => onChanged(options.copyWith(includePulse: v)),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SwitchListTile(
      title: Text(label, style: theme.textTheme.titleMedium),
      value: value,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.lock_outline,
          size: 18,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            AppLocalizations.of(context).exportPrivacyNote,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _ExportButton extends StatelessWidget {
  const _ExportButton({
    required this.count,
    required this.busy,
    required this.onPressed,
  });

  final int count;
  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.dashboardAccentCoral,
            foregroundColor: AppColors.onboardingHeadline,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            textStyle: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          icon: busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.onboardingHeadline,
                  ),
                )
              : const Icon(Icons.file_download_outlined),
          label: Text(AppLocalizations.of(context).exportButton(count)),
        ),
      ),
    );
  }
}
