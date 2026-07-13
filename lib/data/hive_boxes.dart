import 'package:hive_flutter/hive_flutter.dart';
import '../models/txn_kind.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/settings.dart';
import 'seed_categories.dart';

const transactionsBoxName = 'transactions';
const categoriesBoxName = 'categories';
const settingsBoxName = 'settings';
const settingsKey = 'settings';

Future<void> initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TxnKindAdapter());
  Hive.registerAdapter(TransactionRecordAdapter());
  Hive.registerAdapter(CategoryRecordAdapter());
  Hive.registerAdapter(SettingsRecordAdapter());

  final categoriesBox = await Hive.openBox<CategoryRecord>(categoriesBoxName);
  await Hive.openBox<TransactionRecord>(transactionsBoxName);
  final settingsBox = await Hive.openBox<SettingsRecord>(settingsBoxName);

  await seedCategoriesIfEmpty(categoriesBox);
  if (!settingsBox.containsKey(settingsKey)) {
    await settingsBox.put(settingsKey, SettingsRecord());
  }
}

Future<void> seedCategoriesIfEmpty(Box<CategoryRecord> box) async {
  if (box.isNotEmpty) return;
  for (final c in kDefaultCategories) {
    await box.put(
      c.id,
      CategoryRecord(
        id: c.id,
        name: c.name,
        kind: c.kind,
        iconName: c.iconName,
        colorHex: c.colorHex,
        isCustom: c.isCustom,
      ),
    );
  }
}
