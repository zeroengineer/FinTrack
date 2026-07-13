import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/models/txn_kind.dart';
import 'package:finance_tracker/models/category.dart';
import 'package:finance_tracker/data/hive_boxes.dart';
import 'package:finance_tracker/data/seed_categories.dart';
import 'package:finance_tracker/providers/categories_provider.dart';
import 'package:finance_tracker/features/categories/categories_screen.dart';

void main() {
  setUp(() async {
    // In-memory box: widget tests run in a FakeAsync zone where real file
    // IO futures never complete (see docs in onboarding_flow_test.dart).
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(TxnKindAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(CategoryRecordAdapter());
    final catBox = await Hive.openBox<CategoryRecord>(categoriesBoxName, bytes: Uint8List(0));
    await seedCategoriesIfEmpty(catBox);
  });

  tearDown(() async {
    await Hive.close();
  });

  testWidgets('default categories show with no delete button', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MaterialApp(home: CategoriesScreen())));
    expect(find.text('Food'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsNothing);
  });

  testWidgets('adding a custom category shows it with a delete button, which removes it', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MaterialApp(home: CategoriesScreen())));

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('add_category_name_field')), 'Pets');
    await tester.tap(find.byKey(const Key('add_category_save_button')));
    await tester.pumpAndSettle();

    expect(find.text('Pets'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Pets'), findsNothing);
    expect(container.read(categoriesProvider).any((c) => c.name == 'Pets'), false);
  });
}
