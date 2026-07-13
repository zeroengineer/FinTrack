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
import 'package:finance_tracker/features/home/home_screen.dart';

void main() {
  setUp(() async {
    // In-memory boxes: widget tests run in a FakeAsync zone where real file
    // IO futures never complete (see docs in onboarding_flow_test.dart).
    Hive.init(null);
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(TxnKindAdapter());
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(TransactionRecordAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(CategoryRecordAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(SettingsRecordAdapter());
    final catBox = await Hive.openBox<CategoryRecord>(categoriesBoxName, bytes: Uint8List(0));
    await seedCategoriesIfEmpty(catBox);
    final txnBox = await Hive.openBox<TransactionRecord>(transactionsBoxName, bytes: Uint8List(0));
    await txnBox.put('1', TransactionRecord(id: '1', kind: TxnKind.expense, categoryId: 'food', note: 'Lunch at work', amount: 320, date: DateTime.now()));
    final settingsBox = await Hive.openBox<SettingsRecord>(settingsBoxName, bytes: Uint8List(0));
    await settingsBox.put(settingsKey, SettingsRecord(userName: 'Asha', monthlyBudget: 1000, onboardingComplete: true));
  });

  tearDown(() async {
    await Hive.close();
  });

  testWidgets('shows greeting, budget, and the recent transaction', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: HomeScreen())),
      ),
    );

    expect(find.textContaining('Asha'), findsWidgets);
    expect(find.text('Lunch at work'), findsOneWidget);
    expect(find.text('32% used'), findsOneWidget); // 320 / 1000
  });

  testWidgets('empty state: no recent transactions', (tester) async {
    await Hive.box<TransactionRecord>(transactionsBoxName).clear();
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: HomeScreen())),
      ),
    );
    expect(find.text('Lunch at work'), findsNothing);
  });

  testWidgets('tapping Add Expense sets the add-tab and expense draft kind', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: HomeScreen())),
      ),
    );
    await tester.tap(find.text('Add Expense'));
    await tester.pump();
    expect(container.read(currentTabProvider), AppTab.add);
    expect(container.read(addTxnDraftProvider).kind, TxnKind.expense);
  });
}
