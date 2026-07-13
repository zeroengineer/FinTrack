import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/transaction.dart';
import 'package:finance_tracker/models/txn_kind.dart';
import 'package:finance_tracker/utils/analytics.dart';

TransactionRecord _t(TxnKind kind, String cat, double amt, DateTime date) =>
    TransactionRecord(id: '$cat-$amt-$date', kind: kind, categoryId: cat, note: '', amount: amt, date: date);

void main() {
  final now = DateTime(2026, 7, 8);

  group('computeHomeSummary', () {
    test('sums only the current month\'s income/expense', () {
      final txns = [
        _t(TxnKind.income, 'salary', 70000, DateTime(2026, 7, 1)),
        _t(TxnKind.expense, 'food', 320, DateTime(2026, 7, 8)),
        _t(TxnKind.expense, 'food', 999, DateTime(2026, 6, 20)), // last month, excluded
      ];
      final s = computeHomeSummary(txns, now);
      expect(s.income, 70000);
      expect(s.expense, 320);
      expect(s.balance, 70000 - 320);
      expect(s.savings, 70000 - 320);
    });
  });

  group('categoryBreakdown', () {
    test('returns percent-of-total shares sorted descending', () {
      final expenses = [
        _t(TxnKind.expense, 'shopping', 8200, now),
        _t(TxnKind.expense, 'food', 6570, now),
        _t(TxnKind.expense, 'bills', 4800, now),
      ];
      final result = categoryBreakdown(expenses);
      expect(result.map((e) => e.categoryId).toList(), ['shopping', 'food', 'bills']);
      expect(result.first.amount, 8200);
      expect(result.first.percent, closeTo(8200 / (8200 + 6570 + 4800) * 100, 0.001));
    });

    test('empty input returns empty list', () {
      expect(categoryBreakdown([]), isEmpty);
    });
  });

  group('topSpendingCategories', () {
    test('limits results and computes bar fraction relative to the max', () {
      final expenses = [
        _t(TxnKind.expense, 'shopping', 8200, now),
        _t(TxnKind.expense, 'food', 6570, now),
        _t(TxnKind.expense, 'bills', 4800, now),
        _t(TxnKind.expense, 'transport', 3200, now),
        _t(TxnKind.expense, 'others', 1000, now),
      ];
      final result = topSpendingCategories(expenses, limit: 4);
      expect(result.length, 4);
      expect(result.first.barFraction, 1.0);
      expect(result.last.categoryId, 'transport');
    });
  });

  group('monthlySeries', () {
    test('returns exactly `months` entries ending at the current month, ascending', () {
      final txns = [
        _t(TxnKind.income, 'salary', 70000, DateTime(2026, 7, 1)),
        _t(TxnKind.expense, 'food', 27440, DateTime(2026, 7, 5)),
      ];
      final series = monthlySeries(txns, now, months: 6);
      expect(series.length, 6);
      expect(series.last.month, DateTime(2026, 7, 1));
      expect(series.first.month, DateTime(2026, 2, 1));
      expect(series.last.income, 70000);
      expect(series.last.expense, 27440);
    });
  });
}
