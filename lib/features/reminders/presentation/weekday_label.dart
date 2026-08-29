import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';

/// Locale-aware weekday and time helpers shared by the reminders list and
/// form screens (PROJECT_SPEC.md §36). Weekdays are numbered
/// Monday=1..Sunday=7 to match `DateTime.weekday`.
///
/// A fixed reference Monday (2024-01-01) drives the [DateFormat] calls so
/// only the weekday field matters.
DateTime _weekdayDate(int weekday) => DateTime(2024, 1, weekday);

String _locale(BuildContext context) =>
    Localizations.localeOf(context).toString();

/// Abbreviated weekday name, e.g. `Mon`.
String weekdayShortLabel(BuildContext context, int weekday) =>
    DateFormat.E(_locale(context)).format(_weekdayDate(weekday));

/// Narrow (single-letter) weekday name, e.g. `M`.
String weekdayNarrowLabel(BuildContext context, int weekday) =>
    DateFormat('EEEEE', _locale(context)).format(_weekdayDate(weekday));

/// Human-readable summary of a reminder's selected days, e.g. "Every day",
/// "Mon – Fri", or "Mon, Wed, Fri".
String daysSummary(
  BuildContext context,
  AppLocalizations l10n,
  Set<int> daysOfWeek,
) {
  if (daysOfWeek.length == 7) return l10n.remindersEveryDay;
  if (daysOfWeek.length == 5 &&
      !daysOfWeek.contains(6) &&
      !daysOfWeek.contains(7)) {
    return '${weekdayShortLabel(context, 1)} – ${weekdayShortLabel(context, 5)}';
  }
  final sorted = daysOfWeek.toList()..sort();
  return sorted.map((d) => weekdayShortLabel(context, d)).join(', ');
}

/// A picked time of day rendered per the locale's clock convention
/// (12-hour with AM/PM for en, 24-hour elsewhere).
String formatReminderTime(BuildContext context, int hour, int minute) =>
    DateFormat.jm(_locale(context)).format(DateTime(2000, 1, 1, hour, minute));
