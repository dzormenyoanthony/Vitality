import '../../../l10n/app_localizations.dart';

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

  static String? validateSystolic(AppLocalizations l10n, String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return l10n.validationSystolicRequired;
    final parsed = int.tryParse(text);
    if (parsed == null) return l10n.validationSystolicWholeNumber;
    if (parsed < minSystolic || parsed > maxSystolic) {
      return l10n.validationSystolicRange(minSystolic, maxSystolic);
    }
    return null;
  }

  static String? validateDiastolic(AppLocalizations l10n, String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return l10n.validationDiastolicRequired;
    final parsed = int.tryParse(text);
    if (parsed == null) return l10n.validationDiastolicWholeNumber;
    if (parsed < minDiastolic || parsed > maxDiastolic) {
      return l10n.validationDiastolicRange(minDiastolic, maxDiastolic);
    }
    return null;
  }

  /// Pulse is optional — an empty value is valid.
  static String? validatePulse(AppLocalizations l10n, String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final parsed = int.tryParse(text);
    if (parsed == null) return l10n.validationPulseWholeNumber;
    if (parsed < minPulse || parsed > maxPulse) {
      return l10n.validationPulseRange(minPulse, maxPulse);
    }
    return null;
  }
}
