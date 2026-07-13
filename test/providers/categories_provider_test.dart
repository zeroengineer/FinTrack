import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/models/txn_kind.dart';
import 'package:finance_tracker/models/category.dart';
import 'package:finance_tracker/providers/categories_provider.dart';
import 'package:finance_tracker/data/hive_boxes.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(TxnKindAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(CategoryRecordAdapter());
    await Hive.openBox<CategoryRecord>(categoriesBoxName);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    tempDir.deleteSync(recursive: true);
  });

  test('starts with whatever is already in the box', () async {
    await Hive.box<CategoryRecord>(categoriesBoxName).put(
      'food',
      CategoryRecord(id: 'food', name: 'Food', kind: TxnKind.expense, iconName: 'restaurant', colorHex: '#F59E0B'),
    );
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(categoriesProvider).map((c) => c.id), ['food']);
  });

  test('add() persists to the box and updates state', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(categoriesProvider.notifier).add(
      CategoryRecord(id: 'custom1', name: 'Pets', kind: TxnKind.expense, iconName: 'pets', colorHex: '#000000', isCustom: true),
    );
    expect(container.read(categoriesProvider).map((c) => c.id), contains('custom1'));
    expect(Hive.box<CategoryRecord>(categoriesBoxName).get('custom1')!.name, 'Pets');
  });

  test('rename() updates name in place', () async {
    await Hive.box<CategoryRecord>(categoriesBoxName).put(
      'custom1',
      CategoryRecord(id: 'custom1', name: 'Pets', kind: TxnKind.expense, iconName: 'pets', colorHex: '#000000', isCustom: true),
    );
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(categoriesProvider.notifier).rename('custom1', 'Pet Care');
    expect(container.read(categoriesProvider).firstWhere((c) => c.id == 'custom1').name, 'Pet Care');
  });

  test('delete() removes from the box and state', () async {
    await Hive.box<CategoryRecord>(categoriesBoxName).put(
      'custom1',
      CategoryRecord(id: 'custom1', name: 'Pets', kind: TxnKind.expense, iconName: 'pets', colorHex: '#000000', isCustom: true),
    );
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(categoriesProvider.notifier).delete('custom1');
    expect(container.read(categoriesProvider).any((c) => c.id == 'custom1'), false);
  });
}
