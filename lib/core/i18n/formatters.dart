import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Locale-aware date, time, and number formatting (PROJECT_SPEC.md §36).
///
/// Every screen used to carry its own hardcoded English month/weekday
/// tables and hand-assemble strings like `'21 August 2026 · 20:15'`. These
/// helpers replace that with [DateFormat]/[NumberFormat] skeletons resolved
/// against the active locale, so month names, weekday names, field order,
/// and digit shapes follow the device locale.
///
/// Clock convention: Vitaly displays a 24-hour clock everywhere
/// ([DateFormat.Hm]) to match the approved screen designs. The locale still
/// governs the separator and digit representation; only the 12/24-hour
/// choice is fixed by product decision.

String _locale(BuildContext context) =>
    Localizations.localeOf(context).toString();

/// `20:15` — 24-hour time.
String formatTime(BuildContext context, DateTime dt) =>
    DateFormat.Hm(_locale(context)).format(dt);

/// `20:15` — 24-hour clock from a bare hour/minute (e.g. a reminder time
/// with no associated date).
String formatClock(
  BuildContext context, {
  required int hour,
  required int minute,
}) =>
    DateFormat.Hm(_locale(context)).format(DateTime(2000, 1, 1, hour, minute));

/// `Aug 21, 2026` — abbreviated month, day, year (order per locale).
String formatShortDate(BuildContext context, DateTime dt) =>
    DateFormat.yMMMd(_locale(context)).format(dt);

/// `Fri, Aug 21, 2026` — abbreviated weekday, month, day, year.
String formatShortDateWithWeekday(BuildContext context, DateTime dt) =>
    DateFormat.yMMMEd(_locale(context)).format(dt);

/// `Friday, August 21, 2026` — full weekday and month.
String formatLongDate(BuildContext context, DateTime dt) =>
    DateFormat.yMMMMEEEEd(_locale(context)).format(dt);

/// `Aug 21` — abbreviated month and day, no year.
String formatDayMonth(BuildContext context, DateTime dt) =>
    DateFormat.MMMd(_locale(context)).format(dt);

/// `Fri, Aug 21` — abbreviated weekday, month, day, no year.
String formatWeekdayDayMonth(BuildContext context, DateTime dt) =>
    DateFormat.MMMEd(_locale(context)).format(dt);

/// `Aug 2026` — abbreviated month and year.
String formatMonthYear(BuildContext context, DateTime dt) =>
    DateFormat.yMMM(_locale(context)).format(dt);

/// `August 2026` — full month name and year.
String formatMonthYearFull(BuildContext context, DateTime dt) =>
    DateFormat('MMMM y', _locale(context)).format(dt);

/// `Fri` — abbreviated weekday on its own.
String formatWeekdayAbbrev(BuildContext context, DateTime dt) =>
    DateFormat.E(_locale(context)).format(dt);

/// `Friday, August 21, 2026 · 20:15`.
String formatLongDateTime(BuildContext context, DateTime dt) =>
    '${formatLongDate(context, dt)} · ${formatTime(context, dt)}';

/// `Fri, Aug 21, 2026 · 20:15`.
String formatShortDateTimeWithWeekday(BuildContext context, DateTime dt) =>
    '${formatShortDateWithWeekday(context, dt)} · ${formatTime(context, dt)}';

/// `Aug 21, 2026 · 20:15`.
String formatShortDateTime(BuildContext context, DateTime dt) =>
    '${formatShortDate(context, dt)} · ${formatTime(context, dt)}';

/// Locale-aware integer formatting (grouping separators), e.g. `1,024`.
String formatCount(BuildContext context, int value) =>
    NumberFormat.decimalPattern(_locale(context)).format(value);
