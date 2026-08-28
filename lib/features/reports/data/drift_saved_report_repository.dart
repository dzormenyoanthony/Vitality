import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';

import '../../../core/utils/logger.dart';
import '../../blood_pressure/data/app_database.dart';
import '../domain/extracted_reading.dart';
import '../domain/saved_report.dart';
import 'saved_report_repository.dart';

/// Local Drift storage for saved reports, with an optional best-effort push
/// of metadata to Firestore after each write — same pattern as
/// `DriftBloodPressureRepository` (PROJECT_SPEC.md "Scan BP Report" §9-10,
/// §16). Original page files are never stored in Firestore; only their
/// Storage paths are, once `ReportDocumentStorage` uploads them.
class DriftSavedReportRepository implements SavedReportRepository {
  DriftSavedReportRepository(this._db, {this.firestore, this.currentUid});

  final AppDatabase _db;
  final FirebaseFirestore? firestore;
  final String? Function()? currentUid;

  List<ExtractedReading> _parseReadings(String json) {
    final decoded = jsonDecode(json) as List<dynamic>;
    return decoded
        .map((e) => ExtractedReading.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  String _encodeReadings(List<ExtractedReading> readings) {
    return jsonEncode(readings.map((r) => r.toJson()).toList());
  }

  List<String> _splitPaths(String? csv) =>
      csv == null || csv.isEmpty ? const [] : csv.split(',');

  String _joinPaths(List<String> paths) => paths.join(',');

  SavedReport _toDomain(SavedReportRow row) {
    return SavedReport(
      id: row.id,
      remoteId: row.remoteId,
      title: row.title,
      documentType: ReportDocumentType.values.byName(row.documentType),
      reportDate: row.reportDate,
      pageCount: row.pageCount,
      ocrStatus: OcrStatus.values.byName(row.ocrStatus),
      extractedReadings: _parseReadings(row.extractedReadingsJson),
      confirmedReadings: _parseReadings(row.confirmedReadingsJson),
      source: ReportSource.values.byName(row.source),
      localPagePaths: _splitPaths(row.localPagePaths),
      storagePagePaths: row.storagePagePaths == null
          ? null
          : _splitPaths(row.storagePagePaths),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  @override
  Stream<List<SavedReport>> watchAll() {
    final query = _db.select(_db.savedReports)
      ..where((r) => r.deletedAt.isNull())
      ..orderBy([(r) => OrderingTerm.desc(r.createdAt)]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<List<SavedReport>> getAll() async {
    final rows = await (_db.select(
      _db.savedReports,
    )..where((r) => r.deletedAt.isNull())).get();
    return rows.map(_toDomain).toList();
  }

  @override
  Stream<SavedReport?> watchById(int id) {
    final query = _db.select(_db.savedReports)
      ..where((r) => r.id.equals(id) & r.deletedAt.isNull());
    return query.watchSingleOrNull().map((row) => row == null ? null : _toDomain(row));
  }

  @override
  Future<int> add({
    required String title,
    required ReportDocumentType documentType,
    DateTime? reportDate,
    required int pageCount,
    required OcrStatus ocrStatus,
    List<ExtractedReading> extractedReadings = const [],
    List<ExtractedReading> confirmedReadings = const [],
    required ReportSource source,
    required List<String> localPagePaths,
  }) async {
    final now = DateTime.now();
    final id = await _db
        .into(_db.savedReports)
        .insert(
          SavedReportsCompanion.insert(
            title: title,
            documentType: documentType.name,
            reportDate: Value(reportDate),
            pageCount: pageCount,
            ocrStatus: ocrStatus.name,
            extractedReadingsJson: Value(_encodeReadings(extractedReadings)),
            confirmedReadingsJson: Value(_encodeReadings(confirmedReadings)),
            source: source.name,
            localPagePaths: _joinPaths(localPagePaths),
            createdAt: now,
            updatedAt: now,
          ),
        );
    unawaited(_pushToFirestore(id));
    return id;
  }

  @override
  Future<void> updateOcrResult({
    required int id,
    required OcrStatus ocrStatus,
    List<ExtractedReading> extractedReadings = const [],
  }) async {
    await (_db.update(_db.savedReports)..where((r) => r.id.equals(id))).write(
      SavedReportsCompanion(
        ocrStatus: Value(ocrStatus.name),
        extractedReadingsJson: Value(_encodeReadings(extractedReadings)),
        updatedAt: Value(DateTime.now()),
      ),
    );
    unawaited(_pushToFirestore(id));
  }

  @override
  Future<void> updateConfirmedReadings({
    required int id,
    required List<ExtractedReading> confirmedReadings,
  }) async {
    await (_db.update(_db.savedReports)..where((r) => r.id.equals(id))).write(
      SavedReportsCompanion(
        confirmedReadingsJson: Value(_encodeReadings(confirmedReadings)),
        updatedAt: Value(DateTime.now()),
      ),
    );
    unawaited(_pushToFirestore(id));
  }

  @override
  Future<void> rename({required int id, required String title}) async {
    await (_db.update(_db.savedReports)..where((r) => r.id.equals(id))).write(
      SavedReportsCompanion(title: Value(title), updatedAt: Value(DateTime.now())),
    );
    unawaited(_pushToFirestore(id));
  }

  @override
  Future<void> updateStoragePagePaths({
    required int id,
    required List<String> storagePagePaths,
  }) async {
    await (_db.update(_db.savedReports)..where((r) => r.id.equals(id))).write(
      SavedReportsCompanion(
        storagePagePaths: Value(_joinPaths(storagePagePaths)),
        updatedAt: Value(DateTime.now()),
      ),
    );
    unawaited(_pushToFirestore(id));
  }

  @override
  Future<void> delete(int id) async {
    await (_db.update(_db.savedReports)..where((r) => r.id.equals(id))).write(
      SavedReportsCompanion(deletedAt: Value(DateTime.now())),
    );
    unawaited(_pushToFirestore(id));
  }

  @override
  Future<void> deleteAll() {
    return _db.delete(_db.savedReports).go();
  }

  /// Best-effort: pushes the current local state of [id]'s metadata to
  /// Firestore (or deletes the remote doc if soft-deleted). Never throws —
  /// failures are logged and left for the next `SyncCoordinator` pass to
  /// retry, same as `DriftBloodPressureRepository._pushToFirestore`.
  Future<void> _pushToFirestore(int id) async {
    final firestore = this.firestore;
    final uid = currentUid?.call();
    if (firestore == null || uid == null) return;

    try {
      final row = await (_db.select(
        _db.savedReports,
      )..where((r) => r.id.equals(id))).getSingleOrNull();
      if (row == null) return;

      final collection = firestore.collection('users').doc(uid).collection('reports');

      if (row.deletedAt != null) {
        if (row.remoteId != null) {
          await collection.doc(row.remoteId).delete();
        }
        await (_db.delete(_db.savedReports)..where((r) => r.id.equals(id))).go();
        return;
      }

      final docRef = row.remoteId == null ? collection.doc() : collection.doc(row.remoteId);
      await docRef.set({
        'title': row.title,
        'documentType': row.documentType,
        'reportDate': row.reportDate == null ? null : Timestamp.fromDate(row.reportDate!),
        'pageCount': row.pageCount,
        'ocrStatus': row.ocrStatus,
        'extractedReadingsJson': row.extractedReadingsJson,
        'confirmedReadingsJson': row.confirmedReadingsJson,
        'source': row.source,
        'storagePagePaths': row.storagePagePaths,
        'createdAt': Timestamp.fromDate(row.createdAt),
        'updatedAt': Timestamp.fromDate(row.updatedAt),
      }, SetOptions(merge: true));

      if (row.remoteId == null) {
        await (_db.update(_db.savedReports)..where((r) => r.id.equals(id))).write(
          SavedReportsCompanion(remoteId: Value(docRef.id)),
        );
      }
    } catch (error, stackTrace) {
      AppLogger.error('Failed to sync report $id to Firestore', error: error, stackTrace: stackTrace);
    }
  }
}
