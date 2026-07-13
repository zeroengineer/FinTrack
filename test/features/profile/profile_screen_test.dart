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
import 'package:finance_tracker/providers/settings_provider.dart';
import 'package:finance_tracker/providers/pin_provider.dart';
import 'package:finance_tracker/services/reminder_service.dart';
import 'package:finance_tracker/services/export_service.dart';
import 'package:finance_tracker/features/profile/profile_screen.dart';
import 'package:finance_tracker/features/categories/categories_screen.dart';
import 'package:finance_tracker/features/about/about_screen.dart';

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
  bool scheduled = false;
  @override
  Future<void> init() async {}
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<void> scheduleDailyReminder(int minutesSinceMidnight) async => scheduled = true;
  @override
  Future<void> cancelReminder() async => scheduled = false;
}

class _FakeExportService implements ExportService {
  bool shared = false;
  @override
  Future<void> shareCsv(String csv, String fileName) async => shared = true;
}

void main() {
  late _FakeReminderService reminderService;
  late _FakeExportService exportService;

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
    await settingsBox.put(settingsKey, SettingsRecord(userName: 'Asha', monthlySalary: 60000, monthlyBudget: 40000));
    reminderService = _FakeReminderService();
    exportService = _FakeExportService();
  });

  tearDown(() async {
    await Hive.close();
  });

  // The screen is a tall scrollable list; enlarge the test surface so all
  // preference rows are on-screen and tappable.
  void useTallViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  ProviderContainer buildContainer() => ProviderContainer(overrides: [
        pinRepositoryProvider.overrideWithValue(_FakePinRepository()),
        reminderServiceProvider.overrideWithValue(reminderService),
        exportServiceProvider.overrideWithValue(exportService),
      ]);

  testWidgets('shows user name, no fake email, and salary/budget', (tester) async {
    final container = buildContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MaterialApp(home: Scaffold(body: ProfileScreen()))));
    expect(find.text('Asha'), findsOneWidget);
    expect(find.textContaining('@'), findsNothing);
    expect(find.text('₹60,000'), findsOneWidget);
    expect(find.text('₹40,000'), findsOneWidget);
  });

  testWidgets('toggling Reminders on requests permission and schedules', (tester) async {
    final container = buildContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MaterialApp(home: Scaffold(body: ProfileScreen()))));
    await tester.tap(find.text('Reminder Settings'));
    await tester.pumpAndSettle();
    expect(reminderService.scheduled, true);
    expect(container.read(settingsProvider).remindersEnabled, true);
  });

  testWidgets('tapping Export Data shares a CSV', (tester) async {
    final container = buildContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MaterialApp(home: Scaffold(body: ProfileScreen()))));
    await tester.tap(find.text('Export Data'));
    await tester.pumpAndSettle();
    expect(exportService.shared, true);
  });

  testWidgets('tapping Categories navigates to CategoriesScreen', (tester) async {
    final container = buildContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MaterialApp(home: Scaffold(body: ProfileScreen()))));
    await tester.tap(find.text('Categories'));
    await tester.pumpAndSettle();
    expect(find.byType(CategoriesScreen), findsOneWidget);
  });

  testWidgets('tapping About navigates to AboutScreen', (tester) async {
    useTallViewport(tester);
    final container = buildContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MaterialApp(home: Scaffold(body: ProfileScreen()))));
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();
    expect(find.byType(AboutScreen), findsOneWidget);
  });
}
