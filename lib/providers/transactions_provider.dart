import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../data/hive_boxes.dart';
import '../models/transaction.dart';

final transactionsBoxProvider = Provider<Box<TransactionRecord>>((ref) {
  return Hive.box<TransactionRecord>(transactionsBoxName);
});

class TransactionsNotifier extends StateNotifier<List<TransactionRecord>> {
  final Box<TransactionRecord> box;
  TransactionsNotifier(this.box) : super(_sorted(box.values.toList()));

  static List<TransactionRecord> _sorted(List<TransactionRecord> l) =>
      l..sort((a, b) => b.date.compareTo(a.date));

  void _refresh() => state = _sorted(box.values.toList());

  Future<void> add(TransactionRecord t) async {
    await box.put(t.id, t);
    _refresh();
  }

  Future<void> update(TransactionRecord t) async {
    await box.put(t.id, t);
    _refresh();
  }

  Future<void> delete(String id) async {
    await box.delete(id);
    _refresh();
  }
}

final transactionsProvider = StateNotifierProvider<TransactionsNotifier, List<TransactionRecord>>((ref) {
  return TransactionsNotifier(ref.watch(transactionsBoxProvider));
});
