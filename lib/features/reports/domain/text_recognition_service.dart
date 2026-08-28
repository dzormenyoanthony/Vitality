import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Abstraction over on-device OCR (PROJECT_SPEC.md "Scan BP Report" §4).
/// Processing happens entirely on-device — no image or extracted text ever
/// leaves the device, so this feature needs no external-OCR privacy review
/// (spec §16).
abstract interface class TextRecognitionService {
  /// Recognizes all text in the image at [imagePath] and returns it as one
  /// string (line breaks preserved), for [BpValueExtractor] to parse.
  Future<String> recognizeText(String imagePath);

  /// Releases any resources held by the recognizer.
  Future<void> dispose();
}

class MlkitTextRecognitionService implements TextRecognitionService {
  final TextRecognizer _recognizer = TextRecognizer();

  @override
  Future<String> recognizeText(String imagePath) async {
    final result = await _recognizer.processImage(
      InputImage.fromFilePath(imagePath),
    );
    return result.text;
  }

  @override
  Future<void> dispose() => _recognizer.close();
}
