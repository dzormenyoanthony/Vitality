import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitality/core/i18n/formatters.dart';

import '../../support/pump_app.dart';

/// Captures a [BuildContext] resolved to [locale] so the pure formatter
/// functions can be exercised without a full screen. [locale] must be in
/// [supportedLocales] for `Localizations.localeOf` to actually adopt it.
Future<BuildContext> _contextFor(
  WidgetTester tester,
  Locale locale, {
  List<Locale> supportedLocales = const [Locale('en')],
}) async {
  late BuildContext captured;
  await pumpApp(
    tester,
    Builder(
      builder: (context) {
        captured = context;
        return const SizedBox.shrink();
      },
    ),
    locale: locale,
    supportedLocales: supportedLocales,
  );
  return captured;
}

void main() {
  const enUs = Locale('en', 'US');
  const enGb = Locale('en', 'GB');
  final sample = DateTime(2026, 8, 21, 20, 15); // Friday

  group('formatters (en_US)', () {
    testWidgets('formatTime is a 24-hour clock', (tester) async {
      final context = await _contextFor(tester, enUs);
      expect(formatTime(context, sample), '20:15');
      expect(
        formatClock(context, hour: 7, minute: 5),
        '07:05',
      );
    });

    testWidgets('date skeletons resolve to US ordering', (tester) async {
      final context = await _contextFor(tester, enUs);
      expect(formatShortDate(context, sample), 'Aug 21, 2026');
      expect(formatShortDateWithWeekday(context, sample), 'Fri, Aug 21, 2026');
      expect(formatLongDate(context, sample), 'Friday, August 21, 2026');
      expect(formatDayMonth(context, sample), 'Aug 21');
      expect(formatWeekdayDayMonth(context, sample), 'Fri, Aug 21');
      expect(formatMonthYear(context, sample), 'Aug 2026');
      expect(formatWeekdayAbbrev(context, sample), 'Fri');
    });

    testWidgets('composite date+time helpers join with a middot',
        (tester) async {
      final context = await _contextFor(tester, enUs);
      expect(
        formatLongDateTime(context, sample),
        'Friday, August 21, 2026 · 20:15',
      );
      expect(
        formatShortDateTimeWithWeekday(context, sample),
        'Fri, Aug 21, 2026 · 20:15',
      );
      expect(formatShortDateTime(context, sample), 'Aug 21, 2026 · 20:15');
    });

    testWidgets('formatCount groups thousands', (tester) async {
      final context = await _contextFor(tester, enUs);
      expect(formatCount(context, 1024), '1,024');
    });
  });

  group('formatters are locale-sensitive', () {
    testWidgets('en_GB puts the day before the month', (tester) async {
      // Proves the skeletons follow the active locale — the readiness
      // §36 asks for — even though Vitaly only ships en_US today.
      final context = await _contextFor(
        tester,
        enGb,
        supportedLocales: const [Locale('en'), Locale('en', 'GB')],
      );
      expect(formatShortDate(context, sample), '21 Aug 2026');
      expect(formatDayMonth(context, sample), '21 Aug');
    });
  });
}
