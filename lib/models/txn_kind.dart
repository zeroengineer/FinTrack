import 'package:hive/hive.dart';

part 'txn_kind.g.dart';

@HiveType(typeId: 2)
enum TxnKind {
  @HiveField(0)
  expense,
  @HiveField(1)
  income,
}
