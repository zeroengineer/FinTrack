import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/transaction.dart';
import 'package:finance_tracker/models/category.dart';
import 'package:finance_tracker/models/txn_kind.dart';
import 'package:finance_tracker/utils/filtering.dart';

void main() {
  final food = CategoryRecord(id: 'food', name: 'Food', kind: TxnKind.expense, iconName: 'restaurant', colorHex: '#F59E0B');
  final salary = CategoryRecord(id: 'salary', name: 'Salary', kind: TxnKind.income, iconName: 'payments', colorHex: '#22C55E');
  final catsById = {'food': food, 'salary': salary};

  final txns = [
    TransactionRecord(id: '1', kind: TxnKind.expense, categoryId: 'food', note: 'Lunch at work', amount: 320, date: DateTime(2026, 7, 8)),
    TransactionRecord(id: '2', kind: TxnKind.income, categoryId: 'salary', note: 'Monthly salary', amount: 70000, date: DateTime(2026, 7, 1)),
    TransactionRecord(id: '3', kind: TxnKind.expense, categoryId: 'food', note: 'Groceries', amount: 450, date: DateTime(2026, 6, 5)),
  ];

  test('no filters returns everything', () {
    expect(filterTransactions(txns, categoriesById: catsById).length, 3);
  });

  test('search query matches category name or note (case-insensitive)', () {
    expect(filterTransactions(txns, query: 'lunch', categoriesById: catsById).map((t) => t.id), ['1']);
    expect(filterTransactions(txns, query: 'FOOD', categoriesById: catsById).map((t) => t.id), ['1', '3']);
  });

  test('categoryId filter restricts to that category', () {
    expect(filterTransactions(txns, categoryId: 'salary', categoriesById: catsById).map((t) => t.id), ['2']);
  });

  test('kind filter restricts to income or expense', () {
    expect(filterTransactions(txns, kind: TxnKind.income, categoriesById: catsById).map((t) => t.id), ['2']);
  });

  test('month filter restricts to that calendar month', () {
    expect(filterTransactions(txns, month: DateTime(2026, 6), categoriesById: catsById).map((t) => t.id), ['3']);
  });

  test('filters combine', () {
    expect(
      filterTransactions(txns, kind: TxnKind.expense, month: DateTime(2026, 7), categoriesById: catsById).map((t) => t.id),
      ['1'],
    );
  });
}
