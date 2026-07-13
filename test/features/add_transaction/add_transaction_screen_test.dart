import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/models/txn_kind.dart';
import 'package:finance_tracker/models/transaction.dart';
import 'package:finance_tracker/models/category.dart';
import 'package:finance_tracker/data/hive_boxes.dart';
import 'package:finance_tracker/providers/transactions_provider.dart';
import 'package:finance_tracker/providers/app_state.dart';
import 'package:finance_tracker/features/add_transaction/add_transaction_screen.dart';

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

  // The screen is a tall scrollable; enlarge the test surface so the keypad
  // and save button are on-screen and tappable.
  void useTallViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  testWidgets('tapping save without entering an amount shows a validation toast', (tester) async {
    useTallViewport(tester);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MaterialApp(home: Scaffold(body: AddTransactionScreen()))));
    await tester.tap(find.text('Save Transaction'));
    await tester.pump();
    expect(find.text('Enter an amount first'), findsOneWidget);
    expect(container.read(transactionsProvider), isEmpty);
  });

  testWidgets('entering an amount via the keypad, picking a category, and saving adds a transaction', (tester) async {
    useTallViewport(tester);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MaterialApp(home: Scaffold(body: AddTransactionScreen()))));

    await tester.tap(find.text('3'));
    await tester.tap(find.text('2'));
    await tester.tap(find.text('0'));
    await tester.pump();
    expect(find.text('₹320'), findsOneWidget);

    await tester.tap(find.text('Food'));
    await tester.tap(find.text('Save Transaction'));
    await tester.pump();

    final txns = container.read(transactionsProvider);
    expect(txns.length, 1);
    expect(txns.single.amount, 320);
    expect(txns.single.categoryId, 'food');
    expect(container.read(currentTabProvider), AppTab.transactions);
  });
}
