import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/blood_pressure_providers.dart';
import '../data/blood_pressure_reading.dart';

class RecordBpController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Saves a reading. Pass [existingId] to update that reading in place;
  /// omit it to create a new one.
  Future<void> save({
    int? existingId,
    required int systolic,
    required int diastolic,
    int? pulse,
    required DateTime timestamp,
    String? notes,
    List<MeasurementContext> measurementContexts = const [],
    BodyPosition? bodyPosition,
    CuffArm? cuffArm,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(bloodPressureRepositoryProvider);
      if (existingId == null) {
        await repository.addReading(
          systolic: systolic,
          diastolic: diastolic,
          pulse: pulse,
          timestamp: timestamp,
          notes: notes,
          measurementContexts: measurementContexts,
          bodyPosition: bodyPosition,
          cuffArm: cuffArm,
        );
      } else {
        await repository.updateReading(
          id: existingId,
          systolic: systolic,
          diastolic: diastolic,
          pulse: pulse,
          timestamp: timestamp,
          notes: notes,
          measurementContexts: measurementContexts,
          bodyPosition: bodyPosition,
          cuffArm: cuffArm,
        );
      }
    });
  }
}

final recordBpControllerProvider = AsyncNotifierProvider<RecordBpController, void>(
  RecordBpController.new,
);
