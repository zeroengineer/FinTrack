import '../models/category.dart';
import '../models/transaction.dart';
import '../models/txn_kind.dart';

List<TransactionRecord> filterTransactions(
  List<TransactionRecord> all, {
  String query = '',
  String? categoryId,
  TxnKind? kind,
  DateTime? month,
  required Map<String, CategoryRecord> categoriesById,
}) {
  final q = query.trim().toLowerCase();
  return all.where((t) {
    if (categoryId != null && t.categoryId != categoryId) return false;
    if (kind != null && t.kind != kind) return false;
    if (month != null && (t.date.year != month.year || t.date.month != month.month)) return false;
    if (q.isNotEmpty) {
      final catName = categoriesById[t.categoryId]?.name.toLowerCase() ?? '';
      if (!catName.contains(q) && !t.note.toLowerCase().contains(q)) return false;
    }
    return true;
  }).toList();
}
