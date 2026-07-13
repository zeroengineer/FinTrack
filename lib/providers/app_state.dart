import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../models/txn_kind.dart';
import '../utils/analytics.dart';
import '../utils/budget.dart';
import '../utils/date_grouping.dart';
import '../utils/filtering.dart';
import 'categories_provider.dart';
import 'settings_provider.dart';
import 'transactions_provider.dart';

enum AppTab { home, transactions, add, analytics, profile }

final currentTabProvider = StateProvider<AppTab>((ref) => AppTab.home);

/// Whether the current app session has passed the PIN-lock gate. Ignored
/// entirely when `settings.pinLockEnabled` is false. Defaults to false
/// (locked) so a fresh app start with PIN lock enabled requires unlocking;
/// the PIN-unlock screen flips this to true on success.
final sessionUnlockedProvider = StateProvider<bool>((ref) => false);

final categoriesByIdProvider = Provider<Map<String, CategoryRecord>>((ref) {
  final cats = ref.watch(categoriesProvider);
  return {for (final c in cats) c.id: c};
});

final homeSummaryProvider = Provider<HomeSummary>((ref) {
  final txns = ref.watch(transactionsProvider);
  return computeHomeSummary(txns, DateTime.now());
});

final recentTransactionsProvider = Provider<List<TransactionRecord>>((ref) {
  return ref.watch(transactionsProvider).take(3).toList();
});

final budgetPercentProvider = Provider<int>((ref) {
  final summary = ref.watch(homeSummaryProvider);
  final settings = ref.watch(settingsProvider);
  return budgetPercent(summary.expense, settings.monthlyBudget);
});

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedMonthProvider = StateProvider<DateTime?>((ref) => null);
final selectedCategoryIdProvider = StateProvider<String?>((ref) => null);
final selectedKindFilterProvider = StateProvider<TxnKind?>((ref) => null);

final filteredTransactionsProvider = Provider<List<TransactionRecord>>((ref) {
  return filterTransactions(
    ref.watch(transactionsProvider),
    query: ref.watch(searchQueryProvider),
    categoryId: ref.watch(selectedCategoryIdProvider),
    kind: ref.watch(selectedKindFilterProvider),
    month: ref.watch(selectedMonthProvider),
    categoriesById: ref.watch(categoriesByIdProvider),
  );
});

final groupedTransactionsProvider = Provider<List<MapEntry<String, List<TransactionRecord>>>>((ref) {
  final filtered = ref.watch(filteredTransactionsProvider);
  final now = DateTime.now();
  final order = <String>[];
  final map = <String, List<TransactionRecord>>{};
  for (final t in filtered) {
    final label = dayGroupLabel(t.date, now);
    (map[label] ??= []).add(t);
    if (!order.contains(label)) order.add(label);
  }
  return [for (final label in order) MapEntry(label, map[label]!)];
});

final currentMonthExpensesProvider = Provider<List<TransactionRecord>>((ref) {
  final now = DateTime.now();
  return ref.watch(transactionsProvider).where((t) =>
      t.kind == TxnKind.expense && t.date.year == now.year && t.date.month == now.month).toList();
});

final categoryBreakdownProvider = Provider<List<CategoryShare>>((ref) {
  return categoryBreakdown(ref.watch(currentMonthExpensesProvider));
});

final topSpendingCategoriesProvider = Provider<List<TopCategory>>((ref) {
  return topSpendingCategories(ref.watch(currentMonthExpensesProvider));
});

final monthlySeriesProvider = Provider<List<MonthlyTotals>>((ref) {
  return monthlySeries(ref.watch(transactionsProvider), DateTime.now());
});

class AddTxnDraft {
  final TxnKind kind;
  final String amount;
  final String? categoryId;
  final String note;
  final String? editingId;

  const AddTxnDraft({
    this.kind = TxnKind.expense,
    this.amount = '0',
    this.categoryId,
    this.note = '',
    this.editingId,
  });

  AddTxnDraft copyWith({
    TxnKind? kind,
    String? amount,
    String? categoryId,
    bool clearCategoryId = false,
    String? note,
    String? editingId,
    bool clearEditingId = false,
  }) {
    return AddTxnDraft(
      kind: kind ?? this.kind,
      amount: amount ?? this.amount,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      note: note ?? this.note,
      editingId: clearEditingId ? null : (editingId ?? this.editingId),
    );
  }
}

class AddTxnDraftNotifier extends StateNotifier<AddTxnDraft> {
  AddTxnDraftNotifier() : super(const AddTxnDraft());

  void reset({TxnKind kind = TxnKind.expense}) => state = AddTxnDraft(kind: kind);

  void setKind(TxnKind kind) => state = state.copyWith(kind: kind, clearCategoryId: true);

  void setCategory(String id) => state = state.copyWith(categoryId: id);

  void setNote(String note) => state = state.copyWith(note: note);

  void pressKey(String k) {
    var a = state.amount;
    if (k == '.') {
      if (a.contains('.')) return;
      a = '$a.';
    } else if (k == 'back') {
      a = a.length <= 1 ? '0' : a.substring(0, a.length - 1);
    } else {
      if (a.contains('.') && a.split('.')[1].length >= 2) return;
      a = a == '0' ? k : '$a$k';
    }
    if (a.replaceAll('.', '').length > 9) return;
    state = state.copyWith(amount: a);
  }

  void loadForEdit(TransactionRecord t) {
    state = AddTxnDraft(
      kind: t.kind,
      amount: t.amount == t.amount.roundToDouble() ? t.amount.toInt().toString() : t.amount.toString(),
      categoryId: t.categoryId,
      note: t.note,
      editingId: t.id,
    );
  }
}

final addTxnDraftProvider = StateNotifierProvider<AddTxnDraftNotifier, AddTxnDraft>((ref) {
  return AddTxnDraftNotifier();
});
