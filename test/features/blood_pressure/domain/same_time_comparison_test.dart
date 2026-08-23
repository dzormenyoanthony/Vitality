import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/blood_pressure/data/blood_pressure_reading.dart';
import 'package:vitality/features/blood_pressure/domain/same_time_comparison.dart';

BloodPressureReading _reading(int id, DateTime timestamp) => BloodPressureReading(
  id: id,
  systolic: 120,
  diastolic: 80,
  timestamp: timestamp,
  createdAt: timestamp,
  updatedAt: timestamp,
);

void main() {
  test('returns only readings sharing the target AM/PM bucket, target included', () {
    final morning1 = _reading(1, DateTime(2026, 8, 1, 8));
    final evening1 = _reading(2, DateTime(2026, 8, 2, 20));
    final morning2 = _reading(3, DateTime(2026, 8, 3, 9));

    final result = sameTimeOfDayReadings([morning1, evening1, morning2], morning2);

    expect(result, [morning1, morning2]);
  });

  test('caps at maxCount, keeping the most recent (target included)', () {
    final readings = [for (var d = 1; d <= 6; d++) _reading(d, DateTime(2026, 8, d, 8))];
    final target = readings.last;

    final result = sameTimeOfDayReadings(readings, target, maxCount: 5);

    expect(result, hasLength(5));
    expect(result.last, target);
    expect(result.first.id, 2); // days 2..6, day 1 dropped
  });

  test('returns oldest-first order', () {
    final a = _reading(1, DateTime(2026, 8, 1, 8));
    final b = _reading(2, DateTime(2026, 8, 3, 8));
    final c = _reading(3, DateTime(2026, 8, 2, 8));

    final result = sameTimeOfDayReadings([a, b, c], b);

    expect(result.map((r) => r.id).toList(), [1, 3, 2]);
  });

  test('respects morning/evening context tags over raw timestamp hour', () {
    // Tagged "evening" despite an AM timestamp — without the tag
    // overriding the raw hour, this would be bucketed as "morning" and
    // wrongly excluded from an evening target's comparison.
    final taggedEveningAtDawn = BloodPressureReading(
      id: 1,
      systolic: 120,
      diastolic: 80,
      timestamp: DateTime(2026, 8, 1, 6),
      measurementContexts: const [MeasurementContext.evening],
      createdAt: DateTime(2026, 8, 1),
      updatedAt: DateTime(2026, 8, 1),
    );
    final plainEveningTarget = _reading(2, DateTime(2026, 8, 2, 21));

    final result = sameTimeOfDayReadings(
      [taggedEveningAtDawn, plainEveningTarget],
      plainEveningTarget,
    );

    expect(result.map((r) => r.id).toList(), [1, 2]);
  });

  test('returns empty when the target is not present in allReadings', () {
    final target = _reading(99, DateTime(2026, 8, 1, 8));
    final result = sameTimeOfDayReadings([_reading(1, DateTime(2026, 8, 1, 9))], target);
    expect(result, isEmpty);
  });
}
