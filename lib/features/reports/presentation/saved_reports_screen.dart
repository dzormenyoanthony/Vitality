import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/errors/failure.dart';
import '../../../core/theme/app_colors.dart';
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

/// `bytes` formatted as e.g. "640 KB" or "1.8 MB", matching
/// `design_references/My document locker.png`'s size labels.
String formatFileSize(int bytes) {
  if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

/// Lists the signed-in user's saved reports as a "document locker"
/// (`design_references/My document locker.png`): a storage-usage hero
/// card with quick upload/scan actions, category filter chips, and a
/// date-grouped list of cards. View, edit details, and delete.
class SavedReportsScreen extends ConsumerWidget {
  const SavedReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final reportsState = ref.watch(savedReportsStreamProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: reportsState.when(
          loading: () => const LoadingIndicator(),
          error: (error, _) => ErrorView(
            message: friendlyMessage(error),
            onRetry: () => ref.invalidate(savedReportsStreamProvider),
          ),
          data: (reports) => _SavedReportsBody(reports: reports),
        ),
      ),
    );
  }
}

class _SavedReportsBody extends StatefulWidget {
  const _SavedReportsBody({required this.reports});

  final List<SavedReport> reports;

  @override
  State<_SavedReportsBody> createState() => _SavedReportsBodyState();
}

class _SavedReportsBodyState extends State<_SavedReportsBody> {
  ReportCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final reports = widget.reports;
    final filtered = _selectedCategory == null
        ? reports
        : reports.where((r) => r.category == _selectedCategory).toList();
    final now = DateTime.now();
    final thisMonth = <SavedReport>[];
    final earlier = <SavedReport>[];
    for (final report in filtered) {
      final date = report.reportDate ?? report.createdAt;
      (date.year == now.year && date.month == now.month ? thisMonth : earlier).add(report);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      children: [
        Row(
          children: [
            IconButton(
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
            Expanded(
              child: Text(
                'My saved reports',
                style: Theme.of(context).textTheme.headlineMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _DocumentLockerHero(reports: reports),
        const SizedBox(height: AppSpacing.lg),
        if (reports.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: AppSpacing.xl),
            child: EmptyView(
              message: 'No saved reports yet. Scan or import a report to get started.',
              icon: Icons.description_outlined,
            ),
          )
        else ...[
          _CategoryChipsRow(
            reports: reports,
            selected: _selectedCategory,
            onSelected: (c) => setState(() => _selectedCategory = c),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: EmptyView(
                message: 'No reports in this category yet.',
                icon: Icons.filter_list_off_outlined,
              ),
            )
          else ...[
            if (thisMonth.isNotEmpty) ...[
              _SectionLabel('THIS MONTH'),
              const SizedBox(height: AppSpacing.sm),
              for (final report in thisMonth)
                _ReportCard(report: report, accentIndex: filtered.indexOf(report)),
              const SizedBox(height: AppSpacing.md),
            ],
            if (earlier.isNotEmpty) ...[
              _SectionLabel('EARLIER'),
              const SizedBox(height: AppSpacing.sm),
              for (final report in earlier)
                _ReportCard(report: report, accentIndex: filtered.indexOf(report)),
            ],
          ],
          const SizedBox(height: AppSpacing.lg),
          const _FooterNote(),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: AppColors.dashboardAccentTeal,
      ),
    );
  }
}

/// The dark-teal "storage usage" card at the top, matching the reference's
/// "YOUR DOCUMENT LOCKER" card. Always the fixed gradient regardless of
/// app theme — same "always-branded" treatment as the Dashboard latest-
/// reading hero card ([AppColors.heroFill]).
class _DocumentLockerHero extends ConsumerStatefulWidget {
  const _DocumentLockerHero({required this.reports});

  final List<SavedReport> reports;

  @override
  ConsumerState<_DocumentLockerHero> createState() => _DocumentLockerHeroState();
}

class _DocumentLockerHeroState extends ConsumerState<_DocumentLockerHero> {
  late Future<int> _totalBytesFuture;

  @override
  void initState() {
    super.initState();
    _totalBytesFuture = _computeTotal();
  }

  @override
  void didUpdateWidget(covariant _DocumentLockerHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reports != widget.reports) {
      _totalBytesFuture = _computeTotal();
    }
  }

  Future<int> _computeTotal() async {
    final storage = ref.read(reportDocumentStorageProvider);
    var total = 0;
    for (final report in widget.reports) {
      total += await storage.totalSizeBytes(report.localPagePaths);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'YOUR DOCUMENT LOCKER',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.documentLockerEyebrow,
                  ),
                ),
              ),
              const Icon(Icons.lock_outline, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          FutureBuilder<int>(
            future: _totalBytesFuture,
            builder: (context, snapshot) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${widget.reports.length}',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'files · ${formatFileSize(snapshot.data ?? 0)}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.documentLockerMetaText,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => importFromDevice(context, ref),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.documentLockerUploadButtonBg,
                    foregroundColor: AppColors.documentLockerUploadButtonText,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  ),
                  icon: const Icon(Icons.file_upload_outlined, size: 18),
                  label: const Text('Upload report'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => scanWithCamera(context, ref),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0x99BDF0E0)),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  ),
                  child: const Text('Scan a page'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryChipsRow extends StatelessWidget {
  const _CategoryChipsRow({
    required this.reports,
    required this.selected,
    required this.onSelected,
  });

  final List<SavedReport> reports;
  final ReportCategory? selected;
  final ValueChanged<ReportCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    final counts = <ReportCategory, int>{};
    for (final report in reports) {
      counts[report.category] = (counts[report.category] ?? 0) + 1;
    }
    final present = ReportCategory.values.where(counts.containsKey).toList();

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _CategoryChip(
            label: 'All ${reports.length}',
            selected: selected == null,
            onTap: () => onSelected(null),
          ),
          for (final category in present) ...[
            const SizedBox(width: AppSpacing.sm),
            _CategoryChip(
              label: '${category.label} ${counts[category]}',
              selected: selected == category,
              onTap: () => onSelected(category),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onTap(),
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.inverseSurface,
      side: BorderSide(color: selected ? Colors.transparent : theme.colorScheme.outlineVariant),
      shape: const StadiumBorder(),
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: selected ? theme.colorScheme.onInverseSurface : theme.colorScheme.onSurfaceVariant,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
    );
  }
}

class _ReportCard extends ConsumerWidget {
  const _ReportCard({required this.report, required this.accentIndex});

  final SavedReport report;
  final int accentIndex;

  Future<void> _editDetails(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController(text: report.title);
    final providerController = TextEditingController(text: report.provider ?? '');
    var category = report.category;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<ReportCategory>(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: [
                  for (final c in ReportCategory.values)
                    DropdownMenuItem(value: c, child: Text(c.label)),
                ],
                onChanged: (value) {
                  if (value != null) setDialogState(() => category = value);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: providerController,
                decoration: const InputDecoration(labelText: 'Source (optional)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (saved != true) return;
    final newTitle = titleController.text.trim();
    if (newTitle.isEmpty) return;
    await ref
        .read(savedReportRepositoryProvider)
        .updateDetails(
          id: report.id,
          title: newTitle,
          category: category,
          provider: providerController.text.trim().isEmpty
              ? null
              : providerController.text.trim(),
        );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this report?'),
        content: const Text(
          'The saved document and its extracted information will be removed. This cannot be undone.',
        ),
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
    final accents = theme.extension<AppAccentColors>() ?? AppAccentColors.light;
    final (background, foreground) = accents.accents[accentIndex % accents.accents.length];
    final date = report.reportDate ?? report.createdAt;
    final dateLabel = '${date.day} ${_monthShortNames[date.month - 1]}';
    final isPdf = report.documentType == ReportDocumentType.pdf;
    final typeLabel = isPdf ? 'PDF' : 'IMG';

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () => context.push(AppRoutes.reportViewerPath(report.id)),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPdf ? Icons.insert_drive_file_outlined : Icons.image_outlined,
                      color: foreground,
                      size: 18,
                    ),
                    Text(
                      typeLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: foreground,
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
                      report.title,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    FutureBuilder<int>(
                      future: ref
                          .read(reportDocumentStorageProvider)
                          .totalSizeBytes(report.localPagePaths),
                      builder: (context, snapshot) {
                        final parts = [
                          dateLabel,
                          typeLabel,
                          if (snapshot.data != null) formatFileSize(snapshot.data!),
                          if (report.provider != null && report.provider!.trim().isNotEmpty)
                            report.provider!.trim(),
                        ];
                        return Text(
                          parts.join(' · '),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') _editDetails(context, ref);
                  if (value == 'delete') _delete(context, ref);
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit details')),
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

/// Matches the reference's dashed-border footer note exactly in wording.
/// "Attach any report to a reading from its detail view" describes a
/// capability Reading Detail doesn't have yet — kept verbatim per explicit
/// pixel-fidelity direction; flagged as a known gap rather than silently
/// built or silently dropped.
class _FooterNote extends StatelessWidget {
  const _FooterNote();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accents = theme.extension<AppAccentColors>() ?? AppAccentColors.light;
    return _DashedBorder(
      color: accents.mintForeground.withValues(alpha: 0.55),
      radius: AppSpacing.radiusLg,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: accents.mintBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.file_upload_outlined, color: accents.mintForeground, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Files stay on this device unless you share them. Attach any '
                'report to a reading from its detail view.',
                style: theme.textTheme.bodyMedium?.copyWith(color: accents.mintForeground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A dashed rounded-rect border around [child] — no dependency needed for
/// the small amount of path math this takes.
class _DashedBorder extends StatelessWidget {
  const _DashedBorder({required this.child, required this.color, required this.radius});

  final Widget child;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DashedRRectPainter(color: color, radius: radius), child: child);
  }
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  static const _dashWidth = 5.0;
  static const _dashSpace = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final metric in (Path()..addRRect(rrect)).computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + _dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + _dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
