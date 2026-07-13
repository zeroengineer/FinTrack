import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../models/txn_kind.dart';

String transactionsToCsv(List<TransactionRecord> txns, Map<String, CategoryRecord> categoriesById) {
  final dateFmt = DateFormat('yyyy-MM-dd HH:mm');
  final rows = <List<String>>[
    ['Date', 'Type', 'Category', 'Note', 'Amount'],
    ...txns.map((t) => [
          dateFmt.format(t.date),
          t.kind == TxnKind.income ? 'Income' : 'Expense',
          categoriesById[t.categoryId]?.name ?? 'Unknown',
          t.note,
          t.amount.toStringAsFixed(2),
        ]),
  ];
  return const ListToCsvConverter().convert(rows);
}
