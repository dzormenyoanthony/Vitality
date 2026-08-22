import '../data/blood_pressure_reading.dart';

/// Human-readable labels for [MeasurementContext], shared by the record,
/// detail, and history screens.
extension MeasurementContextLabel on MeasurementContext {
  String get label => switch (this) {
    MeasurementContext.morning => 'Morning',
    MeasurementContext.evening => 'Evening',
    MeasurementContext.beforeMedication => 'Before medication',
    MeasurementContext.afterMedication => 'After medication',
    MeasurementContext.afterExercise => 'After exercise',
    MeasurementContext.afterMeal => 'After meal',
    MeasurementContext.other => 'Other',
  };
}
