import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/blood_pressure/data/blood_pressure_reading.dart';
import 'package:vitality/features/blood_pressure/domain/history_filter.dart';

BloodPressureReading _reading({
  required int id,
  required DateTime timestamp,
  List<MeasurementContext> contexts = const [],
  String? notes,
}) => BloodPressureReading(
  id: id,
  systolic: 120,
  diastolic: 80,
  timestamp: timestamp,
  notes: notes,
  measurementContexts: contexts,
  createdAt: timestamp,
  updatedAt: timestamp,
);

void main() {
  final morningByTime = _reading(id: 1, timestamp: DateTime(2026, 8, 1, 7));
  final eveningByTime = _reading(id: 2, timestamp: DateTime(2026, 8, 1, 21));
  final withNotes = _reading(id: 3, timestamp: DateTime(2026, 8, 1, 12), notes: 'Felt stressed');
  final all = [morningByTime, eveningByTime, withNotes];

  test('HistoryFilter.all returns every reading unchanged', () {
    expect(filterReadings(all, HistoryFilter.all), all);
  });

  test('HistoryFilter.morning matches AM timestamps', () {
    expect(filterReadings(all, HistoryFilter.morning), [morningByTime]);
  });

  test('HistoryFilter.evening matches PM timestamps', () {
    expect(filterReadings(all, HistoryFilter.evening), [eveningByTime, withNotes]);
  });

  test('HistoryFilter.withNotes matches only readings with non-empty notes', () {
    expect(filterReadings(all, HistoryFilter.withNotes), [withNotes]);
  });

  test('an explicit context tag overrides the raw timestamp', () {
    final taggedEvening = _reading(
      id: 4,
      timestamp: DateTime(2026, 8, 1, 6),
      contexts: const [MeasurementContext.evening],
    );
    expect(filterReadings([taggedEvening], HistoryFilter.morning), isEmpty);
    expect(filterReadings([taggedEvening], HistoryFilter.evening), [taggedEvening]);
  });
}
