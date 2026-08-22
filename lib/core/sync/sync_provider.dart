import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/blood_pressure/data/blood_pressure_providers.dart';
import 'sync_coordinator.dart';

final syncCoordinatorProvider = Provider<SyncCoordinator>((ref) {
  return SyncCoordinator(ref.watch(appDatabaseProvider), FirebaseFirestore.instance);
});
