import 'package:flutter/services.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';

/// Pages captured from a single scan session, in order.
final class ScannedDocument {
  const ScannedDocument({required this.pageImagePaths});

  final List<String> pageImagePaths;
}

/// Abstraction over the native camera-based document scanning UI
/// (PROJECT_SPEC.md "Scan BP Report" §3). Kept behind an interface —
/// rather than importing `google_mlkit_document_scanner` directly from
/// presentation code — so an iOS-capable implementation can be added later
/// without touching any UI or data-layer code (that package is
/// Android-only today).
abstract interface class DocumentScannerService {
  /// Launches the native scan flow (capture, edge-detect, crop, retake,
  /// multi-page, reorder — all handled by the platform UI). Returns `null`
  /// if the user cancelled without producing any pages.
  Future<ScannedDocument?> scan();
}

/// [DocumentScannerService] backed by Google ML Kit's on-device Document
/// Scanner (Android only).
class MlkitDocumentScannerService implements DocumentScannerService {
  @override
  Future<ScannedDocument?> scan() async {
    final scanner = DocumentScanner(
      options: DocumentScannerOptions(
        documentFormats: const {DocumentFormat.jpeg},
        pageLimit: 10,
        mode: ScannerMode.full,
        isGalleryImport: true,
      ),
    );
    try {
      final result = await scanner.scanDocument();
      final images = result.images;
      if (images == null || images.isEmpty) return null;
      return ScannedDocument(pageImagePaths: images);
    } on PlatformException catch (e) {
      // The native scanner reports a user-cancelled session as a
      // "vision#startDocumentScanner" method-channel error rather than a
      // null/empty result — treat that specific case as "no document",
      // same as any other cancellation, and let real failures propagate.
      if ((e.message ?? '').toLowerCase().contains('cancel')) return null;
      rethrow;
    } finally {
      await scanner.close();
    }
  }
}
