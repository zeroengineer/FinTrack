import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/transaction.dart';
import 'package:finance_tracker/models/category.dart';
import 'package:finance_tracker/models/txn_kind.dart';
import 'package:finance_tracker/utils/csv_export.dart';

void main() {
  test('produces a header row plus one row per transaction', () {
    final food = CategoryRecord(id: 'food', name: 'Food', kind: TxnKind.expense, iconName: 'restaurant', colorHex: '#F59E0B');
    final txns = [
      TransactionRecord(id: '1', kind: TxnKind.expense, categoryId: 'food', note: 'Lunch', amount: 320, date: DateTime(2026, 7, 8, 13, 20)),
    ];
    final csv = transactionsToCsv(txns, {'food': food});
    final lines = csv.trim().split('\r\n');
    expect(lines.first, 'Date,Type,Category,Note,Amount');
    expect(lines[1], '2026-07-08 13:20,Expense,Food,Lunch,320.00');
  });

  test('unknown category id falls back to "Unknown"', () {
    final txns = [
      TransactionRecord(id: '1', kind: TxnKind.income, categoryId: 'missing', note: '', amount: 100, date: DateTime(2026, 1, 1)),
    ];
    final csv = transactionsToCsv(txns, {});
    expect(csv, contains('Unknown'));
  });
}
