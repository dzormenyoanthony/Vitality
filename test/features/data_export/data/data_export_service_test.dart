import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/blood_pressure/data/app_database.dart';
import 'package:vitality/features/blood_pressure/data/drift_blood_pressure_repository.dart';
import 'package:vitality/features/data_export/data/data_export_service.dart';
import 'package:vitality/features/reports/data/drift_saved_report_repository.dart';
import 'package:vitality/features/reports/domain/saved_report.dart';

void main() {
  late AppDatabase db;
  late DriftBloodPressureRepository bloodPressureRepository;
  late DriftSavedReportRepository savedReportRepository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    bloodPressureRepository = DriftBloodPressureRepository(db);
    savedReportRepository = DriftSavedReportRepository(db);
  });

  tearDown(() => db.close());

  DataExportService buildService({
    Future<Uint8List?> Function(String path)? readFileBytes,
  }) {
    return DataExportService(
      bloodPressureRepository: bloodPressureRepository,
      savedReportRepository: savedReportRepository,
      readFileBytes: readFileBytes,
    );
  }

  Archive decode(Uint8List zipBytes) => ZipDecoder().decodeBytes(zipBytes);

  test('names the ZIP and the CSV entry using the export date', () async {
    final service = buildService();

    final result = await service.buildExport(now: DateTime(2026, 3, 5));

    expect(result.filename, 'vitaly_data_export_2026-03-05.zip');
    final archive = decode(result.zipBytes);
    expect(archive.files.map((f) => f.name), contains('vitaly_bp_readings_2026-03-05.csv'));
  });

  test('the CSV entry contains every recorded reading', () async {
    await bloodPressureRepository.addReading(
      systolic: 120,
      diastolic: 80,
      timestamp: DateTime(2026, 3, 1, 8),
    );
    await bloodPressureRepository.addReading(
      systolic: 130,
      diastolic: 85,
      timestamp: DateTime(2026, 3, 2, 20),
    );
    final service = buildService();

    final result = await service.buildExport(now: DateTime(2026, 3, 5));

    expect(result.readingCount, 2);
    final archive = decode(result.zipBytes);
    final csv = utf8.decode(
      archive.files.firstWhere((f) => f.name == 'vitaly_bp_readings_2026-03-05.csv').content,
    );
    final rows = csv.trim().split('\n');
    expect(rows, hasLength(3)); // header + 2 readings
  });

  test('bundles an available single-page report file under scanned_reports/', () async {
    final fileBytes = Uint8List.fromList([1, 2, 3]);
    final reportId = await savedReportRepository.add(
      title: 'Clinic printout',
      documentType: ReportDocumentType.image,
      pageCount: 1,
      ocrStatus: OcrStatus.succeeded,
      source: ReportSource.scan,
      localPagePaths: const ['/fake/page_0.jpg'],
    );
    final service = buildService(
      readFileBytes: (path) async => path == '/fake/page_0.jpg' ? fileBytes : null,
    );

    final result = await service.buildExport();

    expect(result.includedReportFileCount, 1);
    expect(result.missingReportFiles, isEmpty);
    final archive = decode(result.zipBytes);
    final entry = archive.files.firstWhere((f) => f.name == 'scanned_reports/report_$reportId.jpg');
    expect(entry.content, fileBytes);
  });

  test('names every page of a multi-page report distinctly', () async {
    final reportId = await savedReportRepository.add(
      title: 'Multi-page scan',
      documentType: ReportDocumentType.pdf,
      pageCount: 2,
      ocrStatus: OcrStatus.succeeded,
      source: ReportSource.import,
      localPagePaths: const ['/fake/page_0.png', '/fake/page_1.png'],
    );
    final service = buildService(readFileBytes: (_) async => Uint8List.fromList([9]));

    final result = await service.buildExport();

    final archive = decode(result.zipBytes);
    expect(
      archive.files.map((f) => f.name),
      containsAll([
        'scanned_reports/report_${reportId}_page_1.png',
        'scanned_reports/report_${reportId}_page_2.png',
      ]),
    );
  });

  test('a missing report file is skipped and reported, without failing the export', () async {
    await savedReportRepository.add(
      title: 'Lost file report',
      documentType: ReportDocumentType.image,
      pageCount: 1,
      ocrStatus: OcrStatus.succeeded,
      source: ReportSource.scan,
      localPagePaths: const ['/fake/missing.jpg'],
    );
    final service = buildService(readFileBytes: (_) async => null);

    final result = await service.buildExport();

    expect(result.includedReportFileCount, 0);
    expect(result.missingReportFiles, ['Lost file report']);
    final archive = decode(result.zipBytes);
    expect(archive.files.any((f) => f.name.startsWith('scanned_reports/')), isFalse);
  });

  test(
    'identifies a missing page within an otherwise-available multi-page report by number',
    () async {
      await savedReportRepository.add(
        title: 'Partially missing',
        documentType: ReportDocumentType.pdf,
        pageCount: 2,
        ocrStatus: OcrStatus.succeeded,
        source: ReportSource.import,
        localPagePaths: const ['/fake/page_0.png', '/fake/page_1.png'],
      );
      final service = buildService(
        readFileBytes: (path) async => path == '/fake/page_1.png' ? Uint8List.fromList([1]) : null,
      );

      final result = await service.buildExport();

      expect(result.includedReportFileCount, 1);
      expect(result.missingReportFiles, ['Partially missing (page 1)']);
    },
  );

  test('never includes files from another user\'s reports (repository already scopes to signed-in user)', () async {
    // SavedReportRepository.getAll() only ever returns the signed-in user's
    // own reports (PROJECT_SPEC.md §16, §25) — with none saved, the export
    // contains no scanned_reports/ entries at all.
    final service = buildService(readFileBytes: (_) async => Uint8List.fromList([1]));

    final result = await service.buildExport();

    expect(result.includedReportFileCount, 0);
    final archive = decode(result.zipBytes);
    expect(archive.files.any((f) => f.name.startsWith('scanned_reports/')), isFalse);
  });
}
