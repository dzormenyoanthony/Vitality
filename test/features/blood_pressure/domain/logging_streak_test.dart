import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/blood_pressure/data/blood_pressure_reading.dart';
import 'package:vitality/features/blood_pressure/domain/logging_streak.dart';

BloodPressureReading _reading(DateTime timestamp) => BloodPressureReading(
  id: 0,
  systolic: 120,
  diastolic: 80,
  timestamp: timestamp,
  createdAt: timestamp,
  updatedAt: timestamp,
);

void main() {
  test('returns empty stats when there are no readings', () {
    final stats = computeStreakStats([], DateTime(2026, 8, 23, 12));
    expect(stats.currentStreak, 0);
    expect(stats.bestStreak, 0);
    expect(stats.lastActivityDate, isNull);
    expect(stats.recordedToday, isFalse);
    expect(stats.isAtRisk, isFalse);
  });

  test('a single reading today counts as a 1-day streak, recorded today', () {
    final now = DateTime(2026, 8, 23, 12);
    final readings = [_reading(now)];
    final stats = computeStreakStats(readings, now);
    expect(stats.currentStreak, 1);
    expect(stats.bestStreak, 1);
    expect(stats.recordedToday, isTrue);
    expect(stats.isAtRisk, isFalse);
  });

  test('two readings on the same calendar day count as one streak day', () {
    final now = DateTime(2026, 8, 23, 20);
    final readings = [
      _reading(DateTime(2026, 8, 23, 8)),
      _reading(DateTime(2026, 8, 23, 20)),
    ];
    final stats = computeStreakStats(readings, now);
    expect(stats.currentStreak, 1);
  });

  test('a reading just before midnight and another just after do NOT merge into one day', () {
    final now = DateTime(2026, 8, 23, 0, 5);
    final readings = [
      _reading(DateTime(2026, 8, 22, 23, 58)),
      _reading(now),
    ];
    final stats = computeStreakStats(readings, now);
    // Two distinct calendar days, both qualifying and consecutive.
    expect(stats.currentStreak, 2);
  });

  test('readings on consecutive calendar days each extend the streak', () {
    final now = DateTime(2026, 8, 23, 8);
    final readings = [
      _reading(now),
      _reading(now.subtract(const Duration(days: 1))),
      _reading(now.subtract(const Duration(days: 2))),
    ];
    final stats = computeStreakStats(readings, now);
    expect(stats.currentStreak, 3);
    expect(stats.bestStreak, 3);
  });

  test('a missed calendar day stops the current streak', () {
    final now = DateTime(2026, 8, 23, 8);
    final readings = [
      _reading(now),
      _reading(now.subtract(const Duration(days: 1))),
      // Day 2 (now-2) is skipped entirely.
      _reading(now.subtract(const Duration(days: 3))),
    ];
    final stats = computeStreakStats(readings, now);
    expect(stats.currentStreak, 2);
  });

  test('the streak stays current (at risk) when today has no reading yet but yesterday did', () {
    final now = DateTime(2026, 8, 23, 8);
    final readings = [
      _reading(now.subtract(const Duration(days: 1))),
      _reading(now.subtract(const Duration(days: 2))),
    ];
    final stats = computeStreakStats(readings, now);
    expect(stats.currentStreak, 2);
    expect(stats.recordedToday, isFalse);
    expect(stats.isAtRisk, isTrue);
  });

  test('the streak is 0 (not at risk) once a full day has been missed', () {
    final now = DateTime(2026, 8, 23, 8);
    final readings = [
      _reading(now.subtract(const Duration(days: 2))),
    ];
    final stats = computeStreakStats(readings, now);
    expect(stats.currentStreak, 0);
    expect(stats.isAtRisk, isFalse);
  });

  test('best streak can exceed the current streak after a gap', () {
    final now = DateTime(2026, 8, 23, 8);
    final readings = [
      // Current run: just today (1 day).
      _reading(now),
      // An earlier, longer run of 4 consecutive days, with a gap before it.
      _reading(now.subtract(const Duration(days: 10))),
      _reading(now.subtract(const Duration(days: 11))),
      _reading(now.subtract(const Duration(days: 12))),
      _reading(now.subtract(const Duration(days: 13))),
    ];
    final stats = computeStreakStats(readings, now);
    expect(stats.currentStreak, 1);
    expect(stats.bestStreak, 4);
  });

  test('lastActivityDate is the most recent calendar day with a reading', () {
    final now = DateTime(2026, 8, 23, 8);
    final readings = [
      _reading(now.subtract(const Duration(days: 5))),
      _reading(now.subtract(const Duration(days: 1))),
    ];
    final stats = computeStreakStats(readings, now);
    expect(stats.lastActivityDate, DateTime(2026, 8, 22));
  });
}
