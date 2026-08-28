import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../domain/data_export_result.dart';

/// Writes [result]'s ZIP bytes to a temp file under the exact export
/// filename, then opens the native system Share/Save flow (PROJECT_SPEC.md
/// §28's approved export flow) so the user can save it to Files, send it by
/// email, hand it to a clinician, etc.
Future<void> shareDataExport(DataExportResult result) async {
  final tempDir = await getTemporaryDirectory();
  final path = p.join(tempDir.path, result.filename);
  await File(path).writeAsBytes(result.zipBytes);

  await SharePlus.instance.share(
    ShareParams(
      files: [XFile(path, mimeType: 'application/zip', name: result.filename)],
      subject: 'Vitaly data export',
    ),
  );
}
