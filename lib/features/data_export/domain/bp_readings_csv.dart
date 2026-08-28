import '../../blood_pressure/data/blood_pressure_reading.dart';

/// Builds the BP readings CSV for the data-export ZIP (PROJECT_SPEC.md §28).
/// Column order and set are exactly the approved export scope — this is a
/// user-facing data export, not a diagnostic report, so it contains only
/// what the user recorded.
String buildBpReadingsCsv(List<BloodPressureReading> readings) {
  final buffer = StringBuffer()
    ..writeln(
      _csvRow(const [
        'Date',
        'Time',
        'Systolic (mmHg)',
        'Diastolic (mmHg)',
        'Pulse (bpm)',
        'Notes',
        'Measurement Context',
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
        reading.pulse?.toString() ?? '',
        reading.notes ?? '',
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
