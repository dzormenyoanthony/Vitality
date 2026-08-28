import '../../blood_pressure/domain/reading_validator.dart';
import 'extracted_reading.dart';

const _monthNumbers = {
  'jan': 1,
  'feb': 2,
  'mar': 3,
  'apr': 4,
  'may': 5,
  'jun': 6,
  'jul': 7,
  'aug': 8,
  'sep': 9,
  'oct': 10,
  'nov': 11,
  'dec': 12,
};

final _pairPattern = RegExp(r'(\d{2,3})\s*/\s*(\d{2,3})');
final _pulsePattern = RegExp(
  r'pulse[^\d]{0,6}(\d{2,3})|(\d{2,3})\s*bpm',
  caseSensitive: false,
);
final _dayMonthYearPattern = RegExp(
  r'\b(\d{1,2})\s+([A-Za-z]{3,9})\.?\s+(\d{4})\b',
);
// No-year fallback (e.g. "22 Aug — 08:00" in a multi-reading report that
// only prints the year once, elsewhere). Defaults to the current year.
final _dayMonthPattern = RegExp(r'\b(\d{1,2})\s+([A-Za-z]{3,9})\b');
final _monthDayYearPattern = RegExp(
  r'\b([A-Za-z]{3,9})\.?\s+(\d{1,2}),?\s+(\d{4})\b',
);
final _isoDatePattern = RegExp(r'\b(\d{4})-(\d{1,2})-(\d{1,2})\b');
final _slashDatePattern = RegExp(r'\b(\d{1,2})/(\d{1,2})/(\d{4})\b');
final _timePattern = RegExp(r'\b(\d{1,2}):(\d{2})\s*([AaPp][Mm])?\b');
final _systolicLabelPattern = RegExp(r'systolic', caseSensitive: false);
final _diastolicLabelPattern = RegExp(r'diastolic', caseSensitive: false);
final _bareNumberPattern = RegExp(r'(\d{2,3})');

/// Parses OCR'd report text into candidate blood-pressure readings
/// (PROJECT_SPEC.md "Scan BP Report" §4-5, §7). Deterministic and free of
/// any I/O — every result is UNCONFIRMED (spec §14) until a human reviews
/// it on the review screen; this never assumes every number in the text is
/// a blood-pressure value, and never writes to BP History itself.
abstract final class BpValueExtractor {
  static List<ExtractedReading> extract(String recognizedText) {
    final lines = recognizedText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final readings = <ExtractedReading>[];
    var nextId = 0;

    for (var i = 0; i < lines.length; i++) {
      final match = _pairPattern.firstMatch(lines[i]);
      if (match == null) continue;
      final systolic = int.parse(match.group(1)!);
      final diastolic = int.parse(match.group(2)!);
      if (!_isPlausiblePair(systolic, diastolic)) continue;

      readings.add(
        ExtractedReading(
          id: nextId++,
          systolic: systolic,
          diastolic: diastolic,
          pulse: _findNear(lines, i, _extractPulse),
          timestamp: _findNear(lines, i, _extractTimestamp),
        ),
      );
    }

    // Fallback for reports that print each value on its own line under a
    // label (e.g. "Systolic" / "136 mmHg" / "Diastolic" / "84 mmHg")
    // instead of a single "136/84" line — only attempted when the primary
    // pass above found nothing, since a labeled report has no reliable way
    // to distinguish multiple readings from one.
    if (readings.isEmpty) {
      final labeled = _extractLabeledSingleReading(lines);
      if (labeled != null) {
        readings.add(
          ExtractedReading(
            id: nextId++,
            systolic: labeled.systolic,
            diastolic: labeled.diastolic,
            pulse: labeled.pulse,
            timestamp: labeled.timestamp,
          ),
        );
      }
    }

    return readings;
  }

  static bool _isPlausiblePair(int systolic, int diastolic) {
    // Reuses the app's existing input-acceptance bounds (an input check,
    // not a diagnostic threshold — PROJECT_SPEC.md §7) to reject OCR noise
    // (date fragments, page numbers) that happens to match "NNN/NNN"; never
    // surfaced to the user directly.
    return systolic >= ReadingValidator.minSystolic &&
        systolic <= ReadingValidator.maxSystolic &&
        diastolic >= ReadingValidator.minDiastolic &&
        diastolic <= ReadingValidator.maxDiastolic &&
        systolic > diastolic;
  }

  /// Searches [lines] around [anchorIndex] for a value matching
  /// [extractor], preferring the anchor line itself, then its immediate
  /// neighbors, before widening slightly — kept tight so a reading's
  /// pulse/date isn't accidentally borrowed from an adjacent reading in a
  /// multi-reading report (PROJECT_SPEC.md §7).
  static T? _findNear<T>(
    List<String> lines,
    int anchorIndex,
    T? Function(String line) extractor, {
    bool preferForward = false,
  }) {
    final offsets = preferForward ? [1, -1, 2, -2, 0] : [0, -1, 1, -2, 2];
    for (final offset in offsets) {
      final index = anchorIndex + offset;
      if (index < 0 || index >= lines.length) continue;
      final value = extractor(lines[index]);
      if (value != null) return value;
    }
    return null;
  }

  static int? _extractPulse(String line) {
    final match = _pulsePattern.firstMatch(line);
    if (match == null) return null;
    final digits = match.group(1) ?? match.group(2);
    if (digits == null) return null;
    final value = int.parse(digits);
    return value >= ReadingValidator.minPulse && value <= ReadingValidator.maxPulse ? value : null;
  }

  static DateTime? _extractTimestamp(String line) {
    final date = _parseDate(line);
    if (date == null) return null;
    final time = _parseTime(line);
    return time == null
        ? date
        : DateTime(date.year, date.month, date.day, time.$1, time.$2);
  }

  static DateTime? _parseDate(String line) {
    final dayMonthYear = _dayMonthYearPattern.firstMatch(line);
    if (dayMonthYear != null) {
      final month = _monthNumbers[dayMonthYear.group(2)!.toLowerCase().substring(0, 3)];
      if (month != null) {
        return DateTime(
          int.parse(dayMonthYear.group(3)!),
          month,
          int.parse(dayMonthYear.group(1)!),
        );
      }
    }

    final monthDayYear = _monthDayYearPattern.firstMatch(line);
    if (monthDayYear != null) {
      final month = _monthNumbers[monthDayYear.group(1)!.toLowerCase().substring(0, 3)];
      if (month != null) {
        return DateTime(
          int.parse(monthDayYear.group(3)!),
          month,
          int.parse(monthDayYear.group(2)!),
        );
      }
    }

    final iso = _isoDatePattern.firstMatch(line);
    if (iso != null) {
      return DateTime(
        int.parse(iso.group(1)!),
        int.parse(iso.group(2)!),
        int.parse(iso.group(3)!),
      );
    }

    final slash = _slashDatePattern.firstMatch(line);
    if (slash != null) {
      // Interpreted as MM/DD/YYYY — ambiguous with DD/MM/YYYY, but the
      // user reviews and can correct the date before confirming (spec §5).
      final month = int.parse(slash.group(1)!);
      final day = int.parse(slash.group(2)!);
      if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
        return DateTime(int.parse(slash.group(3)!), month, day);
      }
    }

    final dayMonth = _dayMonthPattern.firstMatch(line);
    if (dayMonth != null) {
      final month = _monthNumbers[dayMonth.group(2)!.toLowerCase().substring(0, 3)];
      if (month != null) {
        return DateTime(DateTime.now().year, month, int.parse(dayMonth.group(1)!));
      }
    }

    return null;
  }

  static (int, int)? _parseTime(String line) {
    final match = _timePattern.firstMatch(line);
    if (match == null) return null;
    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    if (hour > 23 || minute > 59) return null;
    final meridiem = match.group(3)?.toLowerCase();
    if (meridiem == 'pm' && hour < 12) hour += 12;
    if (meridiem == 'am' && hour == 12) hour = 0;
    return (hour, minute);
  }

  static ({int systolic, int diastolic, int? pulse, DateTime? timestamp})?
  _extractLabeledSingleReading(List<String> lines) {
    int? systolic;
    int? diastolic;

    for (var i = 0; i < lines.length; i++) {
      if (systolic == null && _systolicLabelPattern.hasMatch(lines[i])) {
        systolic = _findNear(lines, i, _extractBareNumber, preferForward: true);
      }
      if (diastolic == null && _diastolicLabelPattern.hasMatch(lines[i])) {
        diastolic = _findNear(lines, i, _extractBareNumber, preferForward: true);
      }
    }

    if (systolic == null || diastolic == null) return null;
    if (!_isPlausiblePair(systolic, diastolic)) return null;

    int? pulse;
    DateTime? timestamp;
    for (final line in lines) {
      pulse ??= _extractPulse(line);
      timestamp ??= _extractTimestamp(line);
    }

    return (
      systolic: systolic,
      diastolic: diastolic,
      pulse: pulse,
      timestamp: timestamp,
    );
  }

  static int? _extractBareNumber(String line) {
    final match = _bareNumberPattern.firstMatch(line);
    return match == null ? null : int.parse(match.group(1)!);
  }
}
