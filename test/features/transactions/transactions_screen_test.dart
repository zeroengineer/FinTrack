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
import 'package:finance_tracker/features/transactions/transactions_screen.dart';

Future<void> _seed() async {
  // In-memory boxes: widget tests run in a FakeAsync zone where real file
  // IO futures never complete (see docs in onboarding_flow_test.dart).
  final catBox = await Hive.openBox<CategoryRecord>(categoriesBoxName, bytes: Uint8List(0));
  await seedCategoriesIfEmpty(catBox);
  final txnBox = await Hive.openBox<TransactionRecord>(transactionsBoxName, bytes: Uint8List(0));
  await txnBox.put('1', TransactionRecord(id: '1', kind: TxnKind.expense, categoryId: 'food', note: 'Lunch at work', amount: 320, date: DateTime.now()));
  await Hive.openBox<SettingsRecord>(settingsBoxName, bytes: Uint8List(0));
}

void main() {
  setUp(() async {
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(TxnKindAdapter());
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(TransactionRecordAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(CategoryRecordAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(SettingsRecordAdapter());
    await _seed();
  });

  tearDown(() async {
    await Hive.close();
  });

  testWidgets('shows the seeded transaction grouped under Today', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MaterialApp(home: Scaffold(body: TransactionsScreen()))));
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('Lunch at work'), findsOneWidget);
  });

  testWidgets('typing in the search box filters the list', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MaterialApp(home: Scaffold(body: TransactionsScreen()))));
    await tester.enterText(find.byType(TextField), 'zzz-no-match');
    await tester.pump();
    expect(find.text('No transactions found'), findsOneWidget);
  });

  testWidgets('empty state renders when there are no transactions at all', (tester) async {
    await Hive.box<TransactionRecord>(transactionsBoxName).clear();
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MaterialApp(home: Scaffold(body: TransactionsScreen()))));
    expect(find.text('No transactions found'), findsOneWidget);
  });
}
