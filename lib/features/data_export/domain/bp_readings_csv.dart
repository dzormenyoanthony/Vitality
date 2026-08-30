import '../../blood_pressure/data/blood_pressure_reading.dart';

/// Builds the BP readings CSV for the data export (PROJECT_SPEC.md §28).
/// Column order and set are the approved export scope — this is a
/// user-facing data export, not a diagnostic report, so it contains only
/// what the user recorded.
///
/// The optional columns §28 lists as "if available" can be dropped
/// entirely via the export screen's toggles: [includePulse] controls the
/// Pulse column, [includeNotesAndTags] controls both Notes and Measurement
/// Context. The required columns (Date, Time, Systolic, Diastolic, Reading
/// Source, Related Report ID) are always present.
String buildBpReadingsCsv(
  List<BloodPressureReading> readings, {
  bool includePulse = true,
  bool includeNotesAndTags = true,
}) {
  final buffer = StringBuffer()
    ..writeln(
      _csvRow([
        'Date',
        'Time',
        'Systolic (mmHg)',
        'Diastolic (mmHg)',
        if (includePulse) 'Pulse (bpm)',
        if (includeNotesAndTags) 'Notes',
        if (includeNotesAndTags) 'Measurement Context',
        'Reading Source',
        'Related Report ID',
      ]),
    );

  for (final reading in readings) {
    buffer.writeln(
      _csvRow([
        _formatDate(reading.timestamp),
        _formatTime(reading.timestamp),
        reading.systolic.toString(),
        reading.diastolic.toString(),
        if (includePulse) reading.pulse?.toString() ?? '',
        if (includeNotesAndTags) reading.notes ?? '',
        if (includeNotesAndTags)
          reading.measurementContexts.map(_contextLabel).join('; '),
        reading.source == ReadingSource.importedReport ? 'Imported Report' : 'Manual Entry',
        reading.sourceReportId?.toString() ?? '',
      ]),
    );
  }

  return buffer.toString();
}

String _csvRow(List<String> fields) => fields.map(_escapeCsvField).join(',');

String _escapeCsvField(String field) {
  if (field.contains(',') || field.contains('"') || field.contains('\n') || field.contains('\r')) {
    return '"${field.replaceAll('"', '""')}"';
  }
  return field;
}

String _formatDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String _formatTime(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String _contextLabel(MeasurementContext context) => switch (context) {
  MeasurementContext.morning => 'Morning',
  MeasurementContext.evening => 'Evening',
  MeasurementContext.beforeMedication => 'Before medication',
  MeasurementContext.afterMedication => 'After medication',
  MeasurementContext.afterExercise => 'After exercise',
  MeasurementContext.afterMeal => 'After meal',
  MeasurementContext.other => 'Other',
};
