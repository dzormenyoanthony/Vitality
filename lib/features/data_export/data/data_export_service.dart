import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

import '../../blood_pressure/data/blood_pressure_repository.dart';
import '../../reports/data/saved_report_repository.dart';
import '../domain/bp_readings_csv.dart';
import '../domain/data_export_result.dart';

/// Builds the full data-export ZIP (PROJECT_SPEC.md §28): the signed-in
/// user's BP readings as CSV plus every scanned/saved report file that
/// belongs to them.
///
/// Report files are read only from this device's local storage
/// (`SavedReport.localPagePaths`), never from Firebase Storage or another
/// user's data — [SavedReportRepository] already scopes every report to the
/// signed-in user (PROJECT_SPEC.md §16, §25), so there is nothing else to
/// filter here. A report page that can't be read (deleted, not yet synced
/// to this device, etc.) is skipped and reported back via
/// [DataExportResult.missingReportFiles] rather than failing the whole
/// export.
class DataExportService {
  DataExportService({
    required this.bloodPressureRepository,
    required this.savedReportRepository,
    Future<Uint8List?> Function(String path)? readFileBytes,
  }) : _readFileBytes = readFileBytes ?? _defaultReadFileBytes;

  final BloodPressureRepository bloodPressureRepository;
  final SavedReportRepository savedReportRepository;
  final Future<Uint8List?> Function(String path) _readFileBytes;

  static Future<Uint8List?> _defaultReadFileBytes(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return null;
      return await file.readAsBytes();
    } catch (_) {
      return null;
    }
  }

  Future<DataExportResult> buildExport({DateTime? now}) async {
    final exportDate = now ?? DateTime.now();
    final readings = await bloodPressureRepository.getAll();
    final reports = await savedReportRepository.getAll();

    final archive = Archive();

    final csvBytes = utf8.encode(buildBpReadingsCsv(readings));
    archive.addFile(
      ArchiveFile('vitaly_bp_readings_${_formatDate(exportDate)}.csv', csvBytes.length, csvBytes),
    );

    var includedReportFileCount = 0;
    final missingReportFiles = <String>[];

    for (final report in reports) {
      final pages = report.localPagePaths;
      for (var i = 0; i < pages.length; i++) {
        final bytes = await _readFileBytes(pages[i]);
        if (bytes == null) {
          missingReportFiles.add(
            pages.length > 1 ? '${report.title} (page ${i + 1})' : report.title,
          );
          continue;
        }

        final extension = p.extension(pages[i]);
        final entryName = pages.length > 1
            ? 'report_${report.id}_page_${i + 1}$extension'
            : 'report_${report.id}$extension';
        archive.addFile(ArchiveFile('scanned_reports/$entryName', bytes.length, bytes));
        includedReportFileCount++;
      }
    }

    final zipBytes = ZipEncoder().encode(archive);

    return DataExportResult(
      zipBytes: Uint8List.fromList(zipBytes),
      filename: 'vitaly_data_export_${_formatDate(exportDate)}.zip',
      readingCount: readings.length,
      includedReportFileCount: includedReportFileCount,
      missingReportFiles: missingReportFiles,
    );
  }

  String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
