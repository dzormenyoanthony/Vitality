import '../data/blood_pressure_reading.dart';

bool _isMorning(BloodPressureReading r) {
  if (r.measurementContexts.contains(MeasurementContext.morning)) return true;
  if (r.measurementContexts.contains(MeasurementContext.evening)) return false;
  return r.timestamp.hour < 12;
}

/// The last [maxCount] readings (oldest first, [target] included) that
/// share [target]'s morning/evening bucket — the "same time of day"
/// comparison on Reading detail. Bucket is [MeasurementContext.morning]/
/// [MeasurementContext.evening] when tagged, otherwise AM/PM of the
/// timestamp. Empty if [target] isn't found in [allReadings].
List<BloodPressureReading> sameTimeOfDayReadings(
  List<BloodPressureReading> allReadings,
  BloodPressureReading target, {
  int maxCount = 5,
}) {
  final targetIsMorning = _isMorning(target);
  final matching = allReadings.where((r) => _isMorning(r) == targetIsMorning).toList()
    ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

  final index = matching.indexWhere((r) => r.id == target.id);
  if (index == -1) return const [];

  final start = (index - maxCount + 1).clamp(0, matching.length);
  return matching.sublist(start, index + 1);
}
