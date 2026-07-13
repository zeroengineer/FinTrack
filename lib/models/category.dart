import 'package:hive/hive.dart';
import 'txn_kind.dart';

part 'category.g.dart';

@HiveType(typeId: 1)
class CategoryRecord extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  TxnKind kind;
  @HiveField(3)
  String iconName;
  @HiveField(4)
  String colorHex;
  @HiveField(5)
  bool isCustom;

  CategoryRecord({
    required this.id,
    required this.name,
    required this.kind,
    required this.iconName,
    required this.colorHex,
    this.isCustom = false,
  });
}
