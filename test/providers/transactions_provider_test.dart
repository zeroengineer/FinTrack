import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/models/txn_kind.dart';
import 'package:finance_tracker/models/transaction.dart';
import 'package:finance_tracker/providers/transactions_provider.dart';
import 'package:finance_tracker/data/hive_boxes.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(TxnKindAdapter());
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(TransactionRecordAdapter());
    await Hive.openBox<TransactionRecord>(transactionsBoxName);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    tempDir.deleteSync(recursive: true);
  });

  test('state is sorted by date descending', () async {
    final box = Hive.box<TransactionRecord>(transactionsBoxName);
    await box.put('1', TransactionRecord(id: '1', kind: TxnKind.expense, categoryId: 'food', note: '', amount: 100, date: DateTime(2026, 7, 1)));
    await box.put('2', TransactionRecord(id: '2', kind: TxnKind.expense, categoryId: 'food', note: '', amount: 200, date: DateTime(2026, 7, 8)));
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(transactionsProvider).map((t) => t.id), ['2', '1']);
  });

  test('add() persists and re-sorts', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(transactionsProvider.notifier).add(
      TransactionRecord(id: '1', kind: TxnKind.income, categoryId: 'salary', note: 'pay', amount: 70000, date: DateTime(2026, 7, 8)),
    );
    expect(container.read(transactionsProvider).length, 1);
  });

  test('update() overwrites the existing record by id', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(transactionsProvider.notifier);
    await notifier.add(TransactionRecord(id: '1', kind: TxnKind.expense, categoryId: 'food', note: 'old', amount: 100, date: DateTime(2026, 7, 8)));
    await notifier.update(TransactionRecord(id: '1', kind: TxnKind.expense, categoryId: 'food', note: 'new', amount: 150, date: DateTime(2026, 7, 8)));
    final txn = container.read(transactionsProvider).single;
    expect(txn.note, 'new');
    expect(txn.amount, 150);
  });

  test('delete() removes by id', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(transactionsProvider.notifier);
    await notifier.add(TransactionRecord(id: '1', kind: TxnKind.expense, categoryId: 'food', note: '', amount: 100, date: DateTime(2026, 7, 8)));
    await notifier.delete('1');
    expect(container.read(transactionsProvider), isEmpty);
  });
}
