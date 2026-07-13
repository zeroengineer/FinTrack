import '../models/transaction.dart';
import '../models/txn_kind.dart';

class HomeSummary {
  final double income;
  final double expense;
  final double balance;
  const HomeSummary({required this.income, required this.expense, required this.balance});
  double get savings => income - expense;
}

HomeSummary computeHomeSummary(List<TransactionRecord> txns, DateTime now) {
  double income = 0, expense = 0;
  for (final t in txns) {
    if (t.date.year == now.year && t.date.month == now.month) {
      if (t.kind == TxnKind.income) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }
  }
  return HomeSummary(income: income, expense: expense, balance: income - expense);
}

class CategoryShare {
  final String categoryId;
  final double amount;
  final double percent;
  const CategoryShare({required this.categoryId, required this.amount, required this.percent});
}

List<CategoryShare> categoryBreakdown(List<TransactionRecord> expenses) {
  if (expenses.isEmpty) return [];
  final totals = <String, double>{};
  double total = 0;
  for (final t in expenses) {
    totals[t.categoryId] = (totals[t.categoryId] ?? 0) + t.amount;
    total += t.amount;
  }
  final entries = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  return entries
      .map((e) => CategoryShare(
            categoryId: e.key,
            amount: e.value,
            percent: total == 0 ? 0 : e.value / total * 100,
          ))
      .toList();
}

class TopCategory {
  final String categoryId;
  final double amount;
  final double barFraction;
  const TopCategory({required this.categoryId, required this.amount, required this.barFraction});
}

List<TopCategory> topSpendingCategories(List<TransactionRecord> expenses, {int limit = 4}) {
  final totals = <String, double>{};
  for (final t in expenses) {
    totals[t.categoryId] = (totals[t.categoryId] ?? 0) + t.amount;
  }
  final entries = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  final top = entries.take(limit).toList();
  final maxV = top.isEmpty ? 1.0 : top.first.value;
  return top
      .map((e) => TopCategory(
            categoryId: e.key,
            amount: e.value,
            barFraction: maxV == 0 ? 0 : e.value / maxV,
          ))
      .toList();
}

class MonthlyTotals {
  final DateTime month;
  final double income;
  final double expense;
  const MonthlyTotals({required this.month, required this.income, required this.expense});
  double get savings => income - expense;
}

List<MonthlyTotals> monthlySeries(List<TransactionRecord> txns, DateTime now, {int months = 6}) {
  final buckets = <DateTime, MonthlyTotals>{};
  final order = <DateTime>[];
  for (var i = months - 1; i >= 0; i--) {
    final m = DateTime(now.year, now.month - i, 1);
    buckets[m] = MonthlyTotals(month: m, income: 0, expense: 0);
    order.add(m);
  }
  for (final t in txns) {
    final key = DateTime(t.date.year, t.date.month, 1);
    final bucket = buckets[key];
    if (bucket == null) continue;
    buckets[key] = t.kind == TxnKind.income
        ? MonthlyTotals(month: key, income: bucket.income + t.amount, expense: bucket.expense)
        : MonthlyTotals(month: key, income: bucket.income, expense: bucket.expense + t.amount);
  }
  return [for (final m in order) buckets[m]!];
}
