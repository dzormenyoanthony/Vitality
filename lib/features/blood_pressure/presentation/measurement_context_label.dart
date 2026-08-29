import '../../../l10n/app_localizations.dart';
import '../data/blood_pressure_reading.dart';

/// Localized labels for [MeasurementContext], [BodyPosition], and [CuffArm],
/// shared by the record, detail, history, and dashboard screens
/// (PROJECT_SPEC.md §36). Each takes an [AppLocalizations] because these
/// enums are rendered in several places with no single owning widget.
extension MeasurementContextLabel on MeasurementContext {
  String label(AppLocalizations l10n) => switch (this) {
    MeasurementContext.morning => l10n.contextMorning,
    MeasurementContext.evening => l10n.contextEvening,
    MeasurementContext.beforeMedication => l10n.contextBeforeMedication,
    MeasurementContext.afterMedication => l10n.contextAfterMedication,
    MeasurementContext.afterExercise => l10n.contextAfterExercise,
    MeasurementContext.afterMeal => l10n.contextAfterMeal,
    MeasurementContext.other => l10n.contextOther,
  };
}

extension BodyPositionLabel on BodyPosition {
  String label(AppLocalizations l10n) => switch (this) {
    BodyPosition.sitting => l10n.bodyPositionSitting,
    BodyPosition.standing => l10n.bodyPositionStanding,
    BodyPosition.lying => l10n.bodyPositionLying,
  };
}

extension CuffArmLabel on CuffArm {
  String label(AppLocalizations l10n) => switch (this) {
    CuffArm.left => l10n.cuffArmLeft,
    CuffArm.right => l10n.cuffArmRight,
  };
}
