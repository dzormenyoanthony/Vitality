import '../data/blood_pressure_reading.dart';

enum HistoryFilter { all, morning, evening, withNotes }

bool _isMorning(BloodPressureReading r) {
  if (r.measurementContexts.contains(MeasurementContext.morning)) return true;
  if (r.measurementContexts.contains(MeasurementContext.evening)) return false;
  return r.timestamp.hour < 12;
}

/// Client-side filter over already-fetched readings — no new persistence,
/// just a display-only view of existing data (PROJECT_SPEC.md §8).
List<BloodPressureReading> filterReadings(
  List<BloodPressureReading> readings,
  HistoryFilter filter,
) {
  return switch (filter) {
    HistoryFilter.all => readings,
    HistoryFilter.morning => readings.where(_isMorning).toList(),
    HistoryFilter.evening => readings.where((r) => !_isMorning(r)).toList(),
    HistoryFilter.withNotes =>
      readings.where((r) => r.notes != null && r.notes!.isNotEmpty).toList(),
  };
}
