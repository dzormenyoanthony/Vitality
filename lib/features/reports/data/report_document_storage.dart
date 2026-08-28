import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/utils/logger.dart';

/// Persists a saved report's original page files locally, and best-effort
/// mirrors them to Firebase Storage (PROJECT_SPEC.md "Scan BP Report" §8-9,
/// §16). The original document is always written locally first and is
/// never blocked on, or replaced by, the cloud copy.
class ReportDocumentStorage {
  ReportDocumentStorage({this.storage, this.currentUid});

  final FirebaseStorage? storage;
  final String? Function()? currentUid;

  /// Copies the scanner/picker's temporary [sourcePaths] into a permanent,
  /// uniquely named local folder, returning the new paths in the same
  /// order. Independent of any database id — the returned paths are stored
  /// directly on the [SavedReport] row, so nothing else needs to know how
  /// they're organized on disk.
  Future<List<String>> saveLocalPages({required List<String> sourcePaths}) async {
    final supportDir = await getApplicationSupportDirectory();
    final folderKey = DateTime.now().microsecondsSinceEpoch.toString();
    final reportDir = Directory(p.join(supportDir.path, 'reports', folderKey));
    await reportDir.create(recursive: true);

    final savedPaths = <String>[];
    for (var i = 0; i < sourcePaths.length; i++) {
      final source = File(sourcePaths[i]);
      final extension = p.extension(sourcePaths[i]);
      final destination = p.join(reportDir.path, 'page_$i$extension');
      await source.copy(destination);
      savedPaths.add(destination);
    }
    return savedPaths;
  }

  /// Deletes a report's local page files individually. Never throws — a
  /// missing file (already cleaned up, or never synced to this device) is
  /// not an error.
  Future<void> deleteLocalPages(List<String> localPagePaths) async {
    for (final path in localPagePaths) {
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();
      } catch (error, stackTrace) {
        AppLogger.error('Failed to delete local report file', error: error, stackTrace: stackTrace);
      }
    }
  }

  /// Uploads [localPagePaths] to Firebase Storage under
  /// `users/{uid}/reports/{reportId}/page_{n}{ext}`. Returns the uploaded
  /// storage paths, or `null` if not signed in, Storage isn't configured,
  /// or the upload fails — callers treat this as best-effort, matching the
  /// rest of the app's sync pattern (PROJECT_SPEC.md §21-22).
  Future<List<String>?> uploadPages({
    required int reportId,
    required List<String> localPagePaths,
  }) async {
    final storage = this.storage;
    final uid = currentUid?.call();
    if (storage == null || uid == null) return null;

    try {
      final storagePaths = <String>[];
      for (var i = 0; i < localPagePaths.length; i++) {
        final extension = p.extension(localPagePaths[i]);
        final storagePath = 'users/$uid/reports/$reportId/page_$i$extension';
        await storage.ref(storagePath).putFile(File(localPagePaths[i]));
        storagePaths.add(storagePath);
      }
      return storagePaths;
    } catch (error, stackTrace) {
      AppLogger.error('Failed to upload report pages to Storage', error: error, stackTrace: stackTrace);
      return null;
    }
  }
}
