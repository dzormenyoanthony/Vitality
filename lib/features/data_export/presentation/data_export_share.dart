import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../domain/data_export_result.dart';

/// Writes [bytes] to a temp file named [filename], then opens the native
/// system Share/Save flow (PROJECT_SPEC.md §28) so the user can save it to
/// Files, email it, hand it to a clinician, etc. Nothing is retained.
Future<void> shareExportFile({
  required Uint8List bytes,
  required String filename,
  required String mimeType,
}) async {
  final tempDir = await getTemporaryDirectory();
  final path = p.join(tempDir.path, filename);
  await File(path).writeAsBytes(bytes);

  await SharePlus.instance.share(
    ShareParams(
      files: [XFile(path, mimeType: mimeType, name: filename)],
      subject: 'Vitaly data export',
    ),
  );
}

/// Shares a full-archive [DataExportResult] ZIP.
Future<void> shareDataExport(DataExportResult result) => shareExportFile(
  bytes: result.zipBytes,
  filename: result.filename,
  mimeType: 'application/zip',
);
