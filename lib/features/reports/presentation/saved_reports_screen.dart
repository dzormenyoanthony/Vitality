import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/errors/failure.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../data/report_providers.dart';
import '../domain/saved_report.dart';
import 'scan_entry_sheet.dart';

const _monthShortNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
]; // ignore: prefer_const_declarations

/// Lists the signed-in user's saved reports (PROJECT_SPEC.md "Scan BP
/// Report" §10): view, rename, and delete, plus the entry point to start a
/// new scan.
class SavedReportsScreen extends ConsumerWidget {
  const SavedReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsState = ref.watch(savedReportsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved reports'),
        // Reached via `context.go` from the scan/confirm flow, which
        // replaces the nav stack — the default AppBar back button only
        // shows when there's something to pop, so it silently disappears
        // in that case. Always show a way back to Dashboard.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.dashboard);
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'saved-reports-fab',
        onPressed: () => showScanEntrySheet(context, ref),
        icon: const Icon(Icons.document_scanner_outlined),
        label: const Text('Scan report'),
      ),
      body: SafeArea(
        child: reportsState.when(
          loading: () => const LoadingIndicator(),
          error: (error, _) => ErrorView(
            message: friendlyMessage(error),
            onRetry: () => ref.invalidate(savedReportsStreamProvider),
          ),
          data: (reports) {
            if (reports.isEmpty) {
              return const EmptyView(
                message: 'No saved reports yet. Scan or import a BP report to get started.',
                icon: Icons.description_outlined,
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg + AppSpacing.xxl,
              ),
              itemCount: reports.length,
              itemBuilder: (context, index) => _ReportCard(report: reports[index]),
            );
          },
        ),
      ),
    );
  }
}

class _ReportCard extends ConsumerWidget {
  const _ReportCard({required this.report});

  final SavedReport report;

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: report.title);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename report'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newTitle == null || newTitle.isEmpty) return;
    await ref.read(savedReportRepositoryProvider).rename(id: report.id, title: newTitle);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this report?'),
        content: const Text('The saved document and its extracted information will be removed. This cannot be undone.'),
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
    await ref.read(savedReportRepositoryProvider).delete(report.id);
    await ref.read(reportDocumentStorageProvider).deleteLocalPages(report.localPagePaths);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final date = report.reportDate ?? report.createdAt;
    final dateLabel = '${date.day} ${_monthShortNames[date.month - 1]} ${date.year}';
    final ocrLabel = switch (report.ocrStatus) {
      OcrStatus.notProcessed => null,
      OcrStatus.processing => 'Processing…',
      OcrStatus.succeeded => report.confirmedReadings.isEmpty
          ? 'No readings confirmed'
          : '${report.confirmedReadings.length} reading${report.confirmedReadings.length == 1 ? '' : 's'} confirmed',
      OcrStatus.failed => "Couldn't read automatically",
    };

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () => context.push(AppRoutes.reportViewerPath(report.id)),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(report.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      '$dateLabel · ${report.pageCount} page${report.pageCount == 1 ? '' : 's'}',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    if (ocrLabel != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        ocrLabel,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'rename') _rename(context, ref);
                  if (value == 'delete') _delete(context, ref);
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'rename', child: Text('Rename')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
