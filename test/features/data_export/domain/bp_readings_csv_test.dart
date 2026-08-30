import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/blood_pressure/data/blood_pressure_reading.dart';
import 'package:vitality/features/data_export/domain/bp_readings_csv.dart';

BloodPressureReading _reading({
  int id = 1,
  int systolic = 120,
  int diastolic = 80,
  int? pulse,
  DateTime? timestamp,
  String? notes,
  List<MeasurementContext> measurementContexts = const [],
  ReadingSource source = ReadingSource.manual,
  int? sourceReportId,
}) {
  final now = timestamp ?? DateTime(2026, 3, 5, 8, 30);
  return BloodPressureReading(
    id: id,
    systolic: systolic,
    diastolic: diastolic,
    pulse: pulse,
    timestamp: now,
    notes: notes,
    measurementContexts: measurementContexts,
    source: source,
    sourceReportId: sourceReportId,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  test('includes the exact approved header row', () {
    final csv = buildBpReadingsCsv(const []);
    final header = csv.split('\n').first;

    expect(
      header,
      'Date,Time,Systolic (mmHg),Diastolic (mmHg),Pulse (bpm),Notes,'
      'Measurement Context,Reading Source,Related Report ID',
    );
  });

  test('formats a manual-entry reading with no optional fields', () {
    final csv = buildBpReadingsCsv([_reading()]);
    final rows = csv.trim().split('\n');

    expect(rows[1], '2026-03-05,08:30,120,80,,,,Manual Entry,');
  });

  test('includes pulse, notes, and joined measurement contexts when present', () {
    final csv = buildBpReadingsCsv([
      _reading(
        pulse: 72,
        notes: 'felt fine',
        measurementContexts: const [MeasurementContext.morning, MeasurementContext.afterMeal],
      ),
    ]);
    final rows = csv.trim().split('\n');

    expect(
      rows[1],
      '2026-03-05,08:30,120,80,72,felt fine,Morning; After meal,Manual Entry,',
    );
  });

  test('labels an imported reading and includes its related report id', () {
    final csv = buildBpReadingsCsv([
      _reading(source: ReadingSource.importedReport, sourceReportId: 7),
    ]);
    final rows = csv.trim().split('\n');

    expect(rows[1], '2026-03-05,08:30,120,80,,,,Imported Report,7');
  });

  test('quotes a note containing a comma', () {
    final csv = buildBpReadingsCsv([_reading(notes: 'stressed, took a walk after')]);
    final rows = csv.trim().split('\n');

    expect(rows[1], contains('"stressed, took a walk after"'));
  });

  test('escapes a note containing a double quote', () {
    final csv = buildBpReadingsCsv([_reading(notes: 'doctor said "monitor closely"')]);
    final rows = csv.trim().split('\n');

    expect(rows[1], contains('"doctor said ""monitor closely"""'));
  });

  test('drops the Pulse column when includePulse is false', () {
    final csv = buildBpReadingsCsv([_reading(pulse: 72)], includePulse: false);
    final rows = csv.trim().split('\n');

    expect(
      rows.first,
      'Date,Time,Systolic (mmHg),Diastolic (mmHg),Notes,'
      'Measurement Context,Reading Source,Related Report ID',
    );
    expect(rows[1], isNot(contains('72')));
    expect(rows[1], '2026-03-05,08:30,120,80,,,Manual Entry,');
  });

  test('drops Notes and Measurement Context when includeNotesAndTags is false', () {
    final csv = buildBpReadingsCsv(
      [
        _reading(
          pulse: 72,
          notes: 'felt fine',
          measurementContexts: const [MeasurementContext.morning],
        ),
      ],
      includeNotesAndTags: false,
    );
    final rows = csv.trim().split('\n');

    expect(
      rows.first,
      'Date,Time,Systolic (mmHg),Diastolic (mmHg),Pulse (bpm),'
      'Reading Source,Related Report ID',
    );
    expect(rows[1], '2026-03-05,08:30,120,80,72,Manual Entry,');
    expect(rows[1], isNot(contains('felt fine')));
    expect(rows[1], isNot(contains('Morning')));
  });

  test('required columns survive with every optional column off', () {
    final csv = buildBpReadingsCsv(
      [_reading(source: ReadingSource.importedReport, sourceReportId: 7)],
      includePulse: false,
      includeNotesAndTags: false,
    );
    final rows = csv.trim().split('\n');

    expect(
      rows.first,
      'Date,Time,Systolic (mmHg),Diastolic (mmHg),Reading Source,Related Report ID',
    );
    expect(rows[1], '2026-03-05,08:30,120,80,Imported Report,7');
  });

  test('writes one row per reading, in the order given', () {
    final csv = buildBpReadingsCsv([
      _reading(id: 1, systolic: 110, diastolic: 70),
      _reading(id: 2, systolic: 130, diastolic: 85),
    ]);
    final rows = csv.trim().split('\n');

    expect(rows, hasLength(3)); // header + 2 readings
    expect(rows[1], startsWith('2026-03-05,08:30,110,70'));
    expect(rows[2], startsWith('2026-03-05,08:30,130,85'));
  });
}
