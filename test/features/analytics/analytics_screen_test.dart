import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/models/txn_kind.dart';
import 'package:finance_tracker/models/transaction.dart';
import 'package:finance_tracker/models/category.dart';
import 'package:finance_tracker/data/hive_boxes.dart';
import 'package:finance_tracker/features/analytics/analytics_screen.dart';

void main() {
  setUp(() async {
    // In-memory boxes: widget tests run in a FakeAsync zone where real file
    // IO futures never complete (see docs in onboarding_flow_test.dart).
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(TxnKindAdapter());
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(TransactionRecordAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(CategoryRecordAdapter());
    final catBox = await Hive.openBox<CategoryRecord>(categoriesBoxName, bytes: Uint8List(0));
    await seedCategoriesIfEmpty(catBox);
    await Hive.openBox<TransactionRecord>(transactionsBoxName, bytes: Uint8List(0));
  });

  tearDown(() async {
    await Hive.close();
  });

  testWidgets('shows an empty state when there are no transactions yet', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MaterialApp(home: Scaffold(body: AnalyticsScreen()))));
    expect(find.textContaining('Add a transaction'), findsOneWidget);
  });

  testWidgets('renders charts and category breakdown once data exists', (tester) async {
    final txnBox = Hive.box<TransactionRecord>(transactionsBoxName);
    final now = DateTime.now();
    await txnBox.put('1', TransactionRecord(id: '1', kind: TxnKind.expense, categoryId: 'food', note: '', amount: 500, date: now));
    await txnBox.put('2', TransactionRecord(id: '2', kind: TxnKind.income, categoryId: 'salary', note: '', amount: 2000, date: now));

    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MaterialApp(home: Scaffold(body: AnalyticsScreen()))));

    expect(find.text('Food'), findsWidgets);
    expect(find.text('Income vs Expense'), findsOneWidget);
    expect(find.text('Category Breakdown'), findsOneWidget);
    expect(find.text('Monthly Trend'), findsOneWidget);
  });
}
