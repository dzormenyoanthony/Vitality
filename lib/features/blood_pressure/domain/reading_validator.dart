/// Input-validation bounds for a blood-pressure reading (PROJECT_SPEC.md
/// §7). These are acceptance ranges for the app's input form, not
/// diagnostic thresholds — messages must never imply a medical conclusion.
abstract final class ReadingValidator {
  static const int minSystolic = 60;
  static const int maxSystolic = 260;
  static const int minDiastolic = 30;
  static const int maxDiastolic = 150;
  static const int minPulse = 30;
  static const int maxPulse = 220;

  static String? validateSystolic(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter a systolic value.';
    final parsed = int.tryParse(text);
    if (parsed == null) return 'Systolic must be a whole number.';
    if (parsed < minSystolic || parsed > maxSystolic) {
      return 'Systolic must be between $minSystolic and $maxSystolic mmHg.';
    }
    return null;
  }

  static String? validateDiastolic(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter a diastolic value.';
    final parsed = int.tryParse(text);
    if (parsed == null) return 'Diastolic must be a whole number.';
    if (parsed < minDiastolic || parsed > maxDiastolic) {
      return 'Diastolic must be between $minDiastolic and $maxDiastolic mmHg.';
    }
    return null;
  }

  /// Pulse is optional — an empty value is valid.
  static String? validatePulse(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final parsed = int.tryParse(text);
    if (parsed == null) return 'Pulse must be a whole number.';
    if (parsed < minPulse || parsed > maxPulse) {
      return 'Pulse must be between $minPulse and $maxPulse bpm.';
    }
    return null;
  }
}
