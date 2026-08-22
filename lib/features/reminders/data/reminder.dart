/// A blood-pressure measurement reminder (PROJECT_SPEC.md §17).
///
/// "Every day" is simply all 7 [daysOfWeek] selected — there's no separate
/// schedule-type concept to keep in sync with it.
final class Reminder {
  const Reminder({
    required this.id,
    required this.label,
    required this.hour,
    required this.minute,
    required this.daysOfWeek,
    required this.enabled,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String label;

  /// 24-hour clock hour (0-23).
  final int hour;

  /// 0-59.
  final int minute;

  /// `DateTime.weekday` values: 1=Monday..7=Sunday.
  final Set<int> daysOfWeek;

  final bool enabled;
  final DateTime createdAt;
  final DateTime updatedAt;
}
