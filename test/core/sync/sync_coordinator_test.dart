import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/core/sync/sync_coordinator.dart';
import 'package:vitality/features/blood_pressure/data/app_database.dart';

const _uid = 'test-uid';

void main() {
  late AppDatabase db;
  late FakeFirebaseFirestore firestore;
  late SyncCoordinator coordinator;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    firestore = FakeFirebaseFirestore();
    coordinator = SyncCoordinator(db, firestore);
  });

  tearDown(() => db.close());

  group('readings', () {
    test('pulls a remote-only reading into an empty local db', () async {
      final now = DateTime(2026, 1, 1, 10);
      await firestore.collection('users').doc(_uid).collection('readings').doc('remote-1').set({
        'systolic': 120,
        'diastolic': 80,
        'pulse': 70,
        'timestamp': Timestamp.fromDate(now),
        'notes': null,
        'measurementContext': null,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      });

      await coordinator.syncAll(_uid);

      final rows = await db.select(db.readings).get();
      expect(rows, hasLength(1));
      expect(rows.single.systolic, 120);
      expect(rows.single.diastolic, 80);
      expect(rows.single.remoteId, 'remote-1');
    });

    test('pushes a local-only reading up to Firestore', () async {
      final now = DateTime(2026, 1, 1, 10);
      await db
          .into(db.readings)
          .insert(
            ReadingsCompanion.insert(
              systolic: 130,
              diastolic: 85,
              timestamp: now,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await coordinator.syncAll(_uid);

      final snapshot = await firestore.collection('users').doc(_uid).collection('readings').get();
      expect(snapshot.docs, hasLength(1));
      expect(snapshot.docs.single.data()['systolic'], 130);

      final rows = await db.select(db.readings).get();
      expect(rows.single.remoteId, snapshot.docs.single.id);
    });

    test('a newer remote update overwrites an older local row', () async {
      final older = DateTime(2026, 1, 1, 10);
      final newer = DateTime(2026, 1, 2, 10);
      final localId = await db
          .into(db.readings)
          .insert(
            ReadingsCompanion.insert(
              systolic: 120,
              diastolic: 80,
              timestamp: older,
              createdAt: older,
              updatedAt: older,
              remoteId: const Value('remote-1'),
            ),
          );
      await firestore.collection('users').doc(_uid).collection('readings').doc('remote-1').set({
        'systolic': 150,
        'diastolic': 95,
        'pulse': null,
        'timestamp': Timestamp.fromDate(newer),
        'notes': null,
        'measurementContext': null,
        'createdAt': Timestamp.fromDate(older),
        'updatedAt': Timestamp.fromDate(newer),
      });

      await coordinator.syncAll(_uid);

      final row = await (db.select(db.readings)..where((r) => r.id.equals(localId))).getSingle();
      expect(row.systolic, 150);
      expect(row.diastolic, 95);
    });

    test('a newer local update overwrites an older remote doc', () async {
      final older = DateTime(2026, 1, 1, 10);
      final newer = DateTime(2026, 1, 2, 10);
      await firestore.collection('users').doc(_uid).collection('readings').doc('remote-1').set({
        'systolic': 120,
        'diastolic': 80,
        'pulse': null,
        'timestamp': Timestamp.fromDate(older),
        'notes': null,
        'measurementContext': null,
        'createdAt': Timestamp.fromDate(older),
        'updatedAt': Timestamp.fromDate(older),
      });
      await db
          .into(db.readings)
          .insert(
            ReadingsCompanion.insert(
              systolic: 150,
              diastolic: 95,
              timestamp: newer,
              createdAt: older,
              updatedAt: newer,
              remoteId: const Value('remote-1'),
            ),
          );

      await coordinator.syncAll(_uid);

      final doc = await firestore
          .collection('users')
          .doc(_uid)
          .collection('readings')
          .doc('remote-1')
          .get();
      expect(doc.data()!['systolic'], 150);
      expect(doc.data()!['diastolic'], 95);
    });

    test('a soft-deleted synced row is removed from Firestore and hard-deleted locally', () async {
      final now = DateTime(2026, 1, 1, 10);
      final localId = await db
          .into(db.readings)
          .insert(
            ReadingsCompanion.insert(
              systolic: 120,
              diastolic: 80,
              timestamp: now,
              createdAt: now,
              updatedAt: now,
              remoteId: const Value('remote-1'),
            ),
          );
      await firestore.collection('users').doc(_uid).collection('readings').doc('remote-1').set({
        'systolic': 120,
        'diastolic': 80,
        'pulse': null,
        'timestamp': Timestamp.fromDate(now),
        'notes': null,
        'measurementContext': null,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      });
      await (db.update(db.readings)..where((r) => r.id.equals(localId))).write(
        ReadingsCompanion(deletedAt: Value(DateTime.now())),
      );

      await coordinator.syncAll(_uid);

      final doc = await firestore
          .collection('users')
          .doc(_uid)
          .collection('readings')
          .doc('remote-1')
          .get();
      expect(doc.exists, isFalse);
      final rows = await db.select(db.readings).get();
      expect(rows, isEmpty);
    });
  });

  group('reminders', () {
    test('pulls a remote-only reminder into an empty local db', () async {
      final now = DateTime(2026, 1, 1, 10);
      await firestore.collection('users').doc(_uid).collection('reminders').doc('remote-1').set({
        'label': 'Evening check',
        'hour': 18,
        'minute': 30,
        'daysOfWeek': '1,2,3,4,5,6,7',
        'enabled': true,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      });

      await coordinator.syncAll(_uid);

      final rows = await db.select(db.reminders).get();
      expect(rows, hasLength(1));
      expect(rows.single.label, 'Evening check');
      expect(rows.single.hour, 18);
      expect(rows.single.remoteId, 'remote-1');
    });
  });
}
