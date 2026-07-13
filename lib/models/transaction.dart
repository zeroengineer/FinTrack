import 'package:hive/hive.dart';
import 'txn_kind.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class TransactionRecord extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  TxnKind kind;
  @HiveField(2)
  String categoryId;
  @HiveField(3)
  String note;
  @HiveField(4)
  double amount;
  @HiveField(5)
  DateTime date;

  TransactionRecord({
    required this.id,
    required this.kind,
    required this.categoryId,
    required this.note,
    required this.amount,
    required this.date,
  });
}
