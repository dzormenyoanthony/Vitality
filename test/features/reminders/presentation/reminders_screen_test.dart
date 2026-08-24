import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/blood_pressure/data/app_database.dart';
import 'package:vitality/features/blood_pressure/data/blood_pressure_providers.dart';
import 'package:vitality/features/reminders/data/drift_reminder_repository.dart';
import 'package:vitality/features/reminders/data/fake_notification_scheduler.dart';
import 'package:vitality/features/reminders/data/reminder_providers.dart';
import 'package:vitality/features/reminders/presentation/reminders_screen.dart';

void main() {
  testWidgets('shows the empty state when there are no reminders', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final scheduler = FakeNotificationScheduler();
    addTearDown(scheduler.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          notificationSchedulerProvider.overrideWithValue(scheduler),
        ],
        child: const MaterialApp(home: RemindersScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('No reminders yet.'), findsOneWidget);

    await db.close();
  });

  testWidgets('lists a reminder once one has been added', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await DriftReminderRepository(db).addReminder(
      label: 'Morning reading',
      hour: 8,
      minute: 0,
      daysOfWeek: {1, 2, 3, 4, 5, 6, 7},
      enabled: true,
    );
    final scheduler = FakeNotificationScheduler();
    addTearDown(scheduler.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          notificationSchedulerProvider.overrideWithValue(scheduler),
        ],
        child: const MaterialApp(home: RemindersScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('08:00'), findsOneWidget);
    expect(find.text('Every day · Morning · delivering'), findsOneWidget);

    await db.close();
  });

  testWidgets('cancelling the delete swipe keeps the reminder', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await DriftReminderRepository(db).addReminder(
      label: 'Morning reading',
      hour: 8,
      minute: 0,
      daysOfWeek: {1},
      enabled: true,
    );
    final scheduler = FakeNotificationScheduler();
    addTearDown(scheduler.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          notificationSchedulerProvider.overrideWithValue(scheduler),
        ],
        child: const MaterialApp(home: RemindersScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('Delete this reminder?'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('08:00'), findsOneWidget);
    expect(find.text('Mon · Morning · delivering'), findsOneWidget);

    await db.close();
  });
}
