import '../data/blood_pressure_reading.dart';

/// Supported trend time windows (PROJECT_SPEC.md §11).
enum TrendPeriod {
  sevenDays(7),
  thirtyDays(30),
  ninetyDays(90),
  all(null);

  const TrendPeriod(this.days);

  /// Window length in days, or `null` for "all available history".
  final int? days;

  String get label => switch (this) {
    TrendPeriod.sevenDays => '7 days',
    TrendPeriod.thirtyDays => '30 days',
    TrendPeriod.ninetyDays => '90 days',
    TrendPeriod.all => 'All',
  };
}

/// Simple mathematical summary of readings within a [TrendPeriod]
/// (PROJECT_SPEC.md §11). Deliberately contains no interpretation —
/// callers are responsible for phrasing this using only the language
/// patterns approved in §12.
final class TrendStats {
  const TrendStats({
    required this.period,
    required this.readings,
    required this.avgSystolic,
    required this.avgDiastolic,
    required this.avgPulse,
    required this.readingCount,
    required this.previousPeriodReadingCount,
  });

  final TrendPeriod period;

  /// Readings within the period, oldest first (chart-ready order).
  final List<BloodPressureReading> readings;

  final double? avgSystolic;
  final double? avgDiastolic;

  /// Average pulse across only the readings that have one recorded.
  final double? avgPulse;

  final int readingCount;

  /// Number of readings in the equivalent prior window (e.g. the 7 days
  /// before the current 7-day window), enabling the §12-approved
  /// "you recorded fewer/more readings than last period" phrasing.
  /// `null` for [TrendPeriod.all], which has no equivalent prior window.
  final int? previousPeriodReadingCount;

  bool get hasPulseData => avgPulse != null;
}

abstract final class TrendCalculator {
  static TrendStats compute(
    List<BloodPressureReading> allReadings,
    TrendPeriod period,
    DateTime now,
  ) {
    final windowStart = period.days == null
        ? null
        : now.subtract(Duration(days: period.days!));

    final inWindow = allReadings
        .where((r) => windowStart == null || !r.timestamp.isBefore(windowStart))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    int? previousPeriodCount;
    if (period.days != null) {
      final previousStart = windowStart!.subtract(Duration(days: period.days!));
      previousPeriodCount = allReadings
          .where(
            (r) => !r.timestamp.isBefore(previousStart) && r.timestamp.isBefore(windowStart),
          )
          .length;
    }

    return TrendStats(
      period: period,
      readings: inWindow,
      avgSystolic: _average(inWindow.map((r) => r.systolic)),
      avgDiastolic: _average(inWindow.map((r) => r.diastolic)),
      avgPulse: _average(inWindow.where((r) => r.pulse != null).map((r) => r.pulse!)),
      readingCount: inWindow.length,
      previousPeriodReadingCount: previousPeriodCount,
    );
  }

  static double? _average(Iterable<int> values) {
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }
}
