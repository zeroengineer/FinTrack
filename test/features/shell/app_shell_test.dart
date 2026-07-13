import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/models/txn_kind.dart';
import 'package:finance_tracker/models/transaction.dart';
import 'package:finance_tracker/models/category.dart';
import 'package:finance_tracker/models/settings.dart';
import 'package:finance_tracker/data/hive_boxes.dart';
import 'package:finance_tracker/providers/app_state.dart';
import 'package:finance_tracker/providers/pin_provider.dart';
import 'package:finance_tracker/services/reminder_service.dart';
import 'package:finance_tracker/services/export_service.dart';
import 'package:finance_tracker/features/shell/app_shell.dart';

class _FakePinRepository implements PinRepository {
  String? pin;
  @override
  Future<bool> hasPin() async => pin != null;
  @override
  Future<void> setPin(String p) async => pin = p;
  @override
  Future<bool> verifyPin(String p) async => pin == p;
  @override
  Future<void> clearPin() async => pin = null;
}

class _FakeReminderService implements ReminderService {
  @override
  Future<void> init() async {}
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<void> scheduleDailyReminder(int minutesSinceMidnight) async {}
  @override
  Future<void> cancelReminder() async {}
}

class _FakeExportService implements ExportService {
  @override
  Future<void> shareCsv(String csv, String fileName) async {}
}

void main() {
  setUp(() async {
    // In-memory boxes: widget tests run in a FakeAsync zone where real file
    // IO futures never complete (see docs in onboarding_flow_test.dart).
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(TxnKindAdapter());
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(TransactionRecordAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(CategoryRecordAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(SettingsRecordAdapter());
    final catBox = await Hive.openBox<CategoryRecord>(categoriesBoxName, bytes: Uint8List(0));
    await seedCategoriesIfEmpty(catBox);
    await Hive.openBox<TransactionRecord>(transactionsBoxName, bytes: Uint8List(0));
    final settingsBox = await Hive.openBox<SettingsRecord>(settingsBoxName, bytes: Uint8List(0));
    await settingsBox.put(settingsKey, SettingsRecord(userName: 'Asha', onboardingComplete: true));
  });

  tearDown(() async {
    await Hive.close();
  });

  ProviderContainer buildContainer() => ProviderContainer(overrides: [
        pinRepositoryProvider.overrideWithValue(_FakePinRepository()),
        reminderServiceProvider.overrideWithValue(_FakeReminderService()),
        exportServiceProvider.overrideWithValue(_FakeExportService()),
      ]);

  testWidgets('starts on Home and switches tabs via the bottom nav', (tester) async {
    final container = buildContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MaterialApp(home: AppShell())));

    expect(find.text('Recent Transactions'), findsOneWidget);

    await tester.tap(find.text('Transactions'));
    await tester.pump();
    expect(container.read(currentTabProvider), AppTab.transactions);

    await tester.tap(find.text('Analytics'));
    await tester.pump();
    expect(container.read(currentTabProvider), AppTab.analytics);

    await tester.tap(find.text('Profile'));
    await tester.pump();
    expect(container.read(currentTabProvider), AppTab.profile);
  });
}
