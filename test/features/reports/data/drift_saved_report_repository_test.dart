import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/blood_pressure/data/app_database.dart';
import 'package:vitality/features/reports/data/drift_saved_report_repository.dart';
import 'package:vitality/features/reports/domain/extracted_reading.dart';
import 'package:vitality/features/reports/domain/saved_report.dart';

/// `_pushToFirestore` is fire-and-forget — see the identical helper in
/// `drift_blood_pressure_repository_test.dart`.
Future<T> _waitFor<T>(
  Future<T> Function() read,
  bool Function(T value) condition, {
  Duration timeout = const Duration(seconds: 2),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (true) {
    final value = await read();
    if (condition(value)) return value;
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('Condition not met within $timeout');
    }
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}

void main() {
  late AppDatabase db;
  late DriftSavedReportRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = DriftSavedReportRepository(db);
  });

  tearDown(() => db.close());

  test('add makes the report appear in watchAll', () async {
    final id = await repository.add(
      title: 'Scanned report',
      documentType: ReportDocumentType.image,
      pageCount: 1,
      ocrStatus: OcrStatus.succeeded,
      source: ReportSource.scan,
      localPagePaths: ['/tmp/page_0.jpg'],
    );

    final reports = await repository.watchAll().first;

    expect(reports, hasLength(1));
    expect(reports.single.id, id);
    expect(reports.single.title, 'Scanned report');
    expect(reports.single.documentType, ReportDocumentType.image);
    expect(reports.single.ocrStatus, OcrStatus.succeeded);
    expect(reports.single.source, ReportSource.scan);
    expect(reports.single.localPagePaths, ['/tmp/page_0.jpg']);
    expect(reports.single.extractedReadings, isEmpty);
    expect(reports.single.confirmedReadings, isEmpty);
  });

  test('round-trips extracted and confirmed readings through JSON', () async {
    final extracted = [
      const ExtractedReading(id: 0, systolic: 136, diastolic: 84, pulse: 72),
      const ExtractedReading(id: 1, systolic: 129, diastolic: 81),
    ];
    final confirmed = [extracted.first];

    final id = await repository.add(
      title: 'Report with readings',
      documentType: ReportDocumentType.pdf,
      pageCount: 2,
      ocrStatus: OcrStatus.succeeded,
      extractedReadings: extracted,
      confirmedReadings: confirmed,
      source: ReportSource.import,
      localPagePaths: ['/tmp/page_0.png', '/tmp/page_1.png'],
    );

    final report = await repository.watchById(id).first;

    expect(report!.extractedReadings, hasLength(2));
    expect(report.extractedReadings[0].systolic, 136);
    expect(report.extractedReadings[0].pulse, 72);
    expect(report.confirmedReadings, hasLength(1));
    expect(report.confirmedReadings.single.systolic, 136);
  });

  test('getAll returns a one-shot snapshot excluding soft-deleted reports', () async {
    final keepId = await repository.add(
      title: 'Keep',
      documentType: ReportDocumentType.image,
      pageCount: 1,
      ocrStatus: OcrStatus.notProcessed,
      source: ReportSource.scan,
      localPagePaths: ['/tmp/keep.jpg'],
    );
    final deletedId = await repository.add(
      title: 'Deleted',
      documentType: ReportDocumentType.image,
      pageCount: 1,
      ocrStatus: OcrStatus.notProcessed,
      source: ReportSource.scan,
      localPagePaths: ['/tmp/deleted.jpg'],
    );
    await repository.delete(deletedId);

    final reports = await repository.getAll();

    expect(reports.map((r) => r.id), [keepId]);
  });

  test('updateOcrResult updates status and extracted readings', () async {
    final id = await repository.add(
      title: 'Report',
      documentType: ReportDocumentType.image,
      pageCount: 1,
      ocrStatus: OcrStatus.processing,
      source: ReportSource.scan,
      localPagePaths: ['/tmp/page_0.jpg'],
    );

    await repository.updateOcrResult(
      id: id,
      ocrStatus: OcrStatus.failed,
    );

    final report = await repository.watchById(id).first;
    expect(report!.ocrStatus, OcrStatus.failed);
  });

  test('updateConfirmedReadings replaces the confirmed list', () async {
    final id = await repository.add(
      title: 'Report',
      documentType: ReportDocumentType.image,
      pageCount: 1,
      ocrStatus: OcrStatus.succeeded,
      source: ReportSource.scan,
      localPagePaths: ['/tmp/page_0.jpg'],
    );

    await repository.updateConfirmedReadings(
      id: id,
      confirmedReadings: const [ExtractedReading(id: 0, systolic: 120, diastolic: 80)],
    );

    final report = await repository.watchById(id).first;
    expect(report!.confirmedReadings.single.systolic, 120);
  });

  test('rename changes the title', () async {
    final id = await repository.add(
      title: 'Old title',
      documentType: ReportDocumentType.image,
      pageCount: 1,
      ocrStatus: OcrStatus.notProcessed,
      source: ReportSource.scan,
      localPagePaths: ['/tmp/page_0.jpg'],
    );

    await repository.rename(id: id, title: 'New title');

    final report = await repository.watchById(id).first;
    expect(report!.title, 'New title');
  });

  test('defaults to bpReport with no provider when not specified', () async {
    final id = await repository.add(
      title: 'Untagged report',
      documentType: ReportDocumentType.image,
      pageCount: 1,
      ocrStatus: OcrStatus.notProcessed,
      source: ReportSource.scan,
      localPagePaths: ['/tmp/page_0.jpg'],
    );

    final report = await repository.watchById(id).first;
    expect(report!.category, ReportCategory.bpReport);
    expect(report.provider, isNull);
  });

  test('round-trips a chosen category and provider', () async {
    final id = await repository.add(
      title: 'Ambulatory BP monitor',
      documentType: ReportDocumentType.pdf,
      pageCount: 1,
      ocrStatus: OcrStatus.notProcessed,
      source: ReportSource.scan,
      localPagePaths: ['/tmp/page_0.pdf'],
      category: ReportCategory.ecg,
      provider: 'Dr. Okafor',
    );

    final report = await repository.watchById(id).first;
    expect(report!.category, ReportCategory.ecg);
    expect(report.provider, 'Dr. Okafor');
  });

  test('updateDetails changes title, category, and provider together', () async {
    final id = await repository.add(
      title: 'Old title',
      documentType: ReportDocumentType.image,
      pageCount: 1,
      ocrStatus: OcrStatus.notProcessed,
      source: ReportSource.scan,
      localPagePaths: ['/tmp/page_0.jpg'],
    );

    await repository.updateDetails(
      id: id,
      title: 'Lipid panel & metabolic',
      category: ReportCategory.labResults,
      provider: 'Northside Lab',
    );

    final report = await repository.watchById(id).first;
    expect(report!.title, 'Lipid panel & metabolic');
    expect(report.category, ReportCategory.labResults);
    expect(report.provider, 'Northside Lab');
  });

  test('updateStoragePagePaths records the uploaded paths', () async {
    final id = await repository.add(
      title: 'Report',
      documentType: ReportDocumentType.image,
      pageCount: 1,
      ocrStatus: OcrStatus.notProcessed,
      source: ReportSource.scan,
      localPagePaths: ['/tmp/page_0.jpg'],
    );

    await repository.updateStoragePagePaths(
      id: id,
      storagePagePaths: ['users/u/reports/1/page_0.jpg'],
    );

    final report = await repository.watchById(id).first;
    expect(report!.storagePagePaths, ['users/u/reports/1/page_0.jpg']);
  });

  test('delete soft-deletes: removed from watchAll/watchById', () async {
    final id = await repository.add(
      title: 'Report',
      documentType: ReportDocumentType.image,
      pageCount: 1,
      ocrStatus: OcrStatus.notProcessed,
      source: ReportSource.scan,
      localPagePaths: ['/tmp/page_0.jpg'],
    );

    await repository.delete(id);

    expect(await repository.watchAll().first, isEmpty);
    expect(await repository.watchById(id).first, isNull);
  });

  test('deleteAll removes every report', () async {
    await repository.add(
      title: 'A',
      documentType: ReportDocumentType.image,
      pageCount: 1,
      ocrStatus: OcrStatus.notProcessed,
      source: ReportSource.scan,
      localPagePaths: ['/tmp/a.jpg'],
    );
    await repository.add(
      title: 'B',
      documentType: ReportDocumentType.image,
      pageCount: 1,
      ocrStatus: OcrStatus.notProcessed,
      source: ReportSource.scan,
      localPagePaths: ['/tmp/b.jpg'],
    );

    await repository.deleteAll();

    expect(await repository.watchAll().first, isEmpty);
  });

  group('with Firestore configured', () {
    late FakeFirebaseFirestore firestore;
    late DriftSavedReportRepository syncedRepository;
    const uid = 'test-uid';

    setUp(() {
      firestore = FakeFirebaseFirestore();
      syncedRepository = DriftSavedReportRepository(db, firestore: firestore, currentUid: () => uid);
    });

    Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> remoteDocs() async {
      final snapshot = await firestore.collection('users').doc(uid).collection('reports').get();
      return snapshot.docs;
    }

    test('add pushes report metadata to Firestore', () async {
      await syncedRepository.add(
        title: 'Scanned report',
        documentType: ReportDocumentType.image,
        pageCount: 1,
        ocrStatus: OcrStatus.succeeded,
        source: ReportSource.scan,
        localPagePaths: ['/tmp/page_0.jpg'],
      );

      final docs = await _waitFor(() => remoteDocs(), (docs) => docs.isNotEmpty);
      expect(docs.single.data()['title'], 'Scanned report');
      // Local file paths are device-specific and never pushed to Firestore.
      expect(docs.single.data().containsKey('localPagePaths'), isFalse);

      final row = await (db.select(db.savedReports)..limit(1)).getSingle();
      expect(row.remoteId, docs.single.id);
    });

    test('delete removes the pushed report from Firestore and hard-deletes locally', () async {
      final id = await syncedRepository.add(
        title: 'Report',
        documentType: ReportDocumentType.image,
        pageCount: 1,
        ocrStatus: OcrStatus.notProcessed,
        source: ReportSource.scan,
        localPagePaths: ['/tmp/page_0.jpg'],
      );
      await _waitFor(() => remoteDocs(), (docs) => docs.isNotEmpty);

      await syncedRepository.delete(id);

      await _waitFor(() => remoteDocs(), (docs) => docs.isEmpty);
      final rows = await db.select(db.savedReports).get();
      expect(rows, isEmpty);
    });
  });
}
