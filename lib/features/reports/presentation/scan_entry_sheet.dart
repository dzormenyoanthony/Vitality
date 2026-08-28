import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_spacing.dart';
import '../data/report_providers.dart';
import '../domain/saved_report.dart';
import 'review_extracted_screen.dart';

/// Entry point for "Scan BP Report" (PROJECT_SPEC.md "Scan BP Report" §2-3):
/// a small chooser between the native camera scanner and importing an
/// existing image/PDF from the device, then pushes the review screen once
/// pages are available.
Future<void> showScanEntrySheet(BuildContext context, WidgetRef ref) async {
  final choice = await showModalBottomSheet<_EntryChoice>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => const _ScanEntrySheetContent(),
  );
  if (choice == null || !context.mounted) return;

  switch (choice) {
    case _EntryChoice.camera:
      await _scanWithCamera(context, ref);
    case _EntryChoice.import:
      await _importFromDevice(context, ref);
  }
}

enum _EntryChoice { camera, import }

class _ScanEntrySheetContent extends StatelessWidget {
  const _ScanEntrySheetContent();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Scan BP report', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Vitaly will look for blood pressure values, but you always '
              'review and confirm them before anything is saved.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Scan with camera'),
              onTap: () => Navigator.of(context).pop(_EntryChoice.camera),
            ),
            ListTile(
              leading: const Icon(Icons.file_upload_outlined),
              title: const Text('Import from device'),
              subtitle: const Text('Image or PDF'),
              onTap: () => Navigator.of(context).pop(_EntryChoice.import),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opens the native camera scanner directly (no chooser sheet) — used by
/// the Saved Reports "document locker" hero card's "Scan a page" button,
/// which already separates the two entry points into distinct buttons
/// (`design_references/My document locker.png`).
Future<void> scanWithCamera(BuildContext context, WidgetRef ref) => _scanWithCamera(context, ref);

/// Opens the device file picker directly (no chooser sheet) — the hero
/// card's "Upload report" button counterpart to [scanWithCamera].
Future<void> importFromDevice(BuildContext context, WidgetRef ref) => _importFromDevice(context, ref);

Future<void> _scanWithCamera(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final scanner = ref.read(documentScannerServiceProvider);
    final result = await scanner.scan();
    if (result == null || !context.mounted) return;
    _pushReview(
      context,
      pagePaths: result.pageImagePaths,
      documentType: ReportDocumentType.image,
      source: ReportSource.scan,
    );
  } catch (_) {
    messenger.showSnackBar(
      const SnackBar(content: Text("Couldn't open the scanner. Please try again.")),
    );
  }
}

Future<void> _importFromDevice(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (files.isEmpty) return;

    final paths = files.map((f) => f.path).whereType<String>().toList();
    if (paths.isEmpty) return;

    final isPdf = paths.every((path) => p.extension(path).toLowerCase() == '.pdf');
    if (isPdf) {
      final pagePaths = <String>[];
      for (final pdfPath in paths) {
        pagePaths.addAll(await _rasterizePdf(pdfPath));
      }
      if (!context.mounted) return;
      _pushReview(
        context,
        pagePaths: pagePaths,
        documentType: ReportDocumentType.pdf,
        source: ReportSource.import,
      );
    } else {
      if (!context.mounted) return;
      _pushReview(
        context,
        pagePaths: paths,
        documentType: ReportDocumentType.image,
        source: ReportSource.import,
      );
    }
  } catch (_) {
    messenger.showSnackBar(
      const SnackBar(content: Text("Couldn't import that file. Please try again.")),
    );
  }
}

/// Rasterizes every page of the PDF at [pdfPath] into a PNG in the temp
/// directory, reusing the existing `printing` dependency
/// (`trend_pdf_export.dart` already depends on it) instead of adding a
/// dedicated PDF-rendering package.
Future<List<String>> _rasterizePdf(String pdfPath) async {
  final bytes = await File(pdfPath).readAsBytes();
  final tempDir = await getTemporaryDirectory();
  final pagePaths = <String>[];
  var pageIndex = 0;
  await for (final page in Printing.raster(bytes, dpi: 200)) {
    final png = await page.toPng();
    final destination = p.join(
      tempDir.path,
      '${DateTime.now().microsecondsSinceEpoch}_page_$pageIndex.png',
    );
    await File(destination).writeAsBytes(png);
    pagePaths.add(destination);
    pageIndex++;
  }
  return pagePaths;
}

void _pushReview(
  BuildContext context, {
  required List<String> pagePaths,
  required ReportDocumentType documentType,
  required ReportSource source,
}) {
  context.push(
    AppRoutes.reviewExtracted,
    extra: ReviewExtractedArgs(
      rawPagePaths: pagePaths,
      documentType: documentType,
      source: source,
    ),
  );
}
