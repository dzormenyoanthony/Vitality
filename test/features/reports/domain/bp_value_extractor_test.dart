import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/reports/domain/bp_value_extractor.dart';

void main() {
  group('BpValueExtractor', () {
    test('extracts a single "NNN/NNN" reading', () {
      final readings = BpValueExtractor.extract('Blood Pressure\n136/84 mmHg\n');

      expect(readings, hasLength(1));
      expect(readings.single.systolic, 136);
      expect(readings.single.diastolic, 84);
      expect(readings.single.needsReview, isTrue);
    });

    test('extracts multiple readings from the spec\'s example layout', () {
      const text = '''
Detected readings:

22 Aug — 08:00
136 / 84

22 Aug — 14:00
129 / 81

22 Aug — 20:00
142 / 90
''';

      final readings = BpValueExtractor.extract(text);

      expect(readings, hasLength(3));
      expect(readings.map((r) => (r.systolic, r.diastolic)).toList(), [
        (136, 84),
        (129, 81),
        (142, 90),
      ]);
      for (final r in readings) {
        expect(r.timestamp, isNotNull);
        expect(r.timestamp!.month, 8);
        expect(r.timestamp!.day, 22);
      }
      expect(readings[0].timestamp!.hour, 8);
      expect(readings[1].timestamp!.hour, 14);
      expect(readings[2].timestamp!.hour, 20);
    });

    test('extracts pulse near a reading when present', () {
      final readings = BpValueExtractor.extract('136/84 mmHg\nPulse 72 bpm');

      expect(readings.single.pulse, 72);
    });

    test('does not extract a pulse when none is present', () {
      final readings = BpValueExtractor.extract('136/84 mmHg\nNotes: felt fine');

      expect(readings.single.pulse, isNull);
    });

    test('extracts the labeled single-reading layout from the spec\'s review example', () {
      const text = '''
Blood Pressure

Systolic
136 mmHg

Diastolic
84 mmHg

Pulse
72 bpm

Date
22 Aug 2026
''';

      final readings = BpValueExtractor.extract(text);

      expect(readings, hasLength(1));
      final reading = readings.single;
      expect(reading.systolic, 136);
      expect(reading.diastolic, 84);
      expect(reading.pulse, 72);
      expect(reading.timestamp, DateTime(2026, 8, 22));
    });

    test('parses ISO and slash date formats', () {
      expect(
        BpValueExtractor.extract('120/80\n2026-03-05').single.timestamp,
        DateTime(2026, 3, 5),
      );
      expect(
        BpValueExtractor.extract('120/80\n03/05/2026').single.timestamp,
        DateTime(2026, 3, 5),
      );
    });

    test('does not treat unrelated numbers or a date as a BP reading', () {
      const text = '''
Page 1 of 3
Patient ID: 4821
Report generated 22/08/2026
''';

      expect(BpValueExtractor.extract(text), isEmpty);
    });

    test('returns nothing for text with no plausible reading', () {
      expect(BpValueExtractor.extract('Thank you for visiting our clinic.'), isEmpty);
    });

    test('rejects an implausible "NNN/NNN" match (e.g. a date fragment)', () {
      // "22/08" from a dd/mm date would otherwise match the pair pattern;
      // the plausibility filter (diastolic too low, systolic <= diastolic)
      // must reject it.
      expect(BpValueExtractor.extract('22/08/2026'), isEmpty);
    });

    test('assigns each reading a unique id', () {
      const text = '136/84\n129/81';
      final readings = BpValueExtractor.extract(text);
      expect(readings.map((r) => r.id).toSet(), hasLength(2));
    });
  });
}
