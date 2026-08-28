import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/errors/failure.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../data/report_providers.dart';
import '../domain/saved_report.dart';

/// Views a saved report's original pages (PROJECT_SPEC.md "Scan BP Report"
/// §11): multi-page, zoomable, full-screen. Always shows the preserved
/// original document, never OCR text in its place.
class ReportViewerScreen extends ConsumerWidget {
  const ReportViewerScreen({super.key, required this.reportId});

  final int reportId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportState = ref.watch(savedReportStreamProvider(reportId));

    return Scaffold(
      appBar: AppBar(
        title: Text(reportState.value?.title ?? 'Report'),
      ),
      body: SafeArea(
        child: reportState.when(
          loading: () => const LoadingIndicator(),
          error: (error, _) => ErrorView(message: friendlyMessage(error)),
          data: (report) {
            if (report == null) {
              return const ErrorView(message: 'This report is no longer available.');
            }
            return _ReportPages(report: report);
          },
        ),
      ),
    );
  }
}

class _ReportPages extends StatefulWidget {
  const _ReportPages({required this.report});

  final SavedReport report;

  @override
  State<_ReportPages> createState() => _ReportPagesState();
}

class _ReportPagesState extends State<_ReportPages> {
  late final PageController _pageController;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paths = widget.report.localPagePaths;
    if (paths.isEmpty) {
      return const ErrorView(
        message: "This report's original document isn't available on this device.",
      );
    }

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: paths.length,
            onPageChanged: (index) => setState(() => _page = index),
            itemBuilder: (context, index) {
              final file = File(paths[index]);
              if (!file.existsSync()) {
                return const ErrorView(
                  message: "This page isn't available offline.",
                );
              }
              return InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Center(child: Image.file(file)),
              );
            },
          ),
        ),
        if (paths.length > 1)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              'Page ${_page + 1} of ${paths.length}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
      ],
    );
  }
}
