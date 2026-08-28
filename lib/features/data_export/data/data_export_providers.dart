import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../blood_pressure/data/blood_pressure_providers.dart';
import '../../reports/data/report_providers.dart';
import 'data_export_service.dart';

final dataExportServiceProvider = Provider<DataExportService>((ref) {
  return DataExportService(
    bloodPressureRepository: ref.watch(bloodPressureRepositoryProvider),
    savedReportRepository: ref.watch(savedReportRepositoryProvider),
  );
});
