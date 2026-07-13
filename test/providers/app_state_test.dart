import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/models/txn_kind.dart';
import 'package:finance_tracker/models/transaction.dart';
import 'package:finance_tracker/models/category.dart';
import 'package:finance_tracker/models/settings.dart';
import 'package:finance_tracker/data/hive_boxes.dart';
import 'package:finance_tracker/data/seed_categories.dart';
import 'package:finance_tracker/providers/app_state.dart';

void main() {
  late Directory tempDir;
  late DateTime now;

  setUp(() async {
    now = DateTime.now();
    tempDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(TxnKindAdapter());
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(TransactionRecordAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(CategoryRecordAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(SettingsRecordAdapter());
    final catBox = await Hive.openBox<CategoryRecord>(categoriesBoxName);
    await seedCategoriesIfEmpty(catBox);
    await Hive.openBox<TransactionRecord>(transactionsBoxName);
    final settingsBox = await Hive.openBox<SettingsRecord>(settingsBoxName);
    await settingsBox.put(settingsKey, SettingsRecord(monthlyBudget: 1000));
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    tempDir.deleteSync(recursive: true);
  });

  test('homeSummaryProvider + budgetPercentProvider reflect stored transactions', () async {
    final txnBox = Hive.box<TransactionRecord>(transactionsBoxName);
    await txnBox.put('1', TransactionRecord(id: '1', kind: TxnKind.expense, categoryId: 'food', note: '', amount: 500, date: now));
    await txnBox.put('2', TransactionRecord(id: '2', kind: TxnKind.income, categoryId: 'salary', note: '', amount: 2000, date: now));

    final container = ProviderContainer();
    addTearDown(container.dispose);
    final summary = container.read(homeSummaryProvider);
    expect(summary.expense, 500);
    expect(summary.income, 2000);
    expect(container.read(budgetPercentProvider), 50); // 500 / 1000 budget
  });

  test('filteredTransactionsProvider responds to searchQueryProvider changes', () async {
    final txnBox = Hive.box<TransactionRecord>(transactionsBoxName);
    await txnBox.put('1', TransactionRecord(id: '1', kind: TxnKind.expense, categoryId: 'food', note: 'Lunch', amount: 100, date: now));
    await txnBox.put('2', TransactionRecord(id: '2', kind: TxnKind.expense, categoryId: 'transport', note: 'Bus', amount: 50, date: now));

    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(filteredTransactionsProvider).length, 2);
    container.read(searchQueryProvider.notifier).state = 'lunch';
    expect(container.read(filteredTransactionsProvider).map((t) => t.id), ['1']);
  });

  test('groupedTransactionsProvider groups by day label', () async {
    final txnBox = Hive.box<TransactionRecord>(transactionsBoxName);
    await txnBox.put('1', TransactionRecord(id: '1', kind: TxnKind.expense, categoryId: 'food', note: '', amount: 100, date: now));

    final container = ProviderContainer();
    addTearDown(container.dispose);
    final grouped = container.read(groupedTransactionsProvider);
    expect(grouped.single.key, 'Today');
    expect(grouped.single.value.single.id, '1');
  });

  test('addTxnDraftProvider pressKey builds up the amount string', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(addTxnDraftProvider.notifier);
    notifier.pressKey('3');
    notifier.pressKey('2');
    notifier.pressKey('0');
    expect(container.read(addTxnDraftProvider).amount, '320');
    notifier.pressKey('back');
    expect(container.read(addTxnDraftProvider).amount, '32');
  });

  test('sessionUnlockedProvider defaults to false (locked)', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(sessionUnlockedProvider), false);
    container.read(sessionUnlockedProvider.notifier).state = true;
    expect(container.read(sessionUnlockedProvider), true);
  });
}
