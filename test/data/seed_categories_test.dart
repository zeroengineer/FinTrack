import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/data/seed_categories.dart';
import 'package:finance_tracker/models/txn_kind.dart';

void main() {
  test('there are exactly 15 default categories (10 expense, 5 income)', () {
    expect(kDefaultCategories.length, 15);
    expect(kDefaultCategories.where((c) => c.kind == TxnKind.expense).length, 10);
    expect(kDefaultCategories.where((c) => c.kind == TxnKind.income).length, 5);
  });

  test('every default category is non-custom and has a unique id', () {
    expect(kDefaultCategories.every((c) => c.isCustom == false), true);
    final ids = kDefaultCategories.map((c) => c.id).toSet();
    expect(ids.length, kDefaultCategories.length);
  });

  test('Food category matches the design mapping', () {
    final food = kDefaultCategories.firstWhere((c) => c.id == 'food');
    expect(food.name, 'Food');
    expect(food.iconName, 'restaurant');
    expect(food.colorHex, '#F59E0B');
  });
}
