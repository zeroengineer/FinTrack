import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../data/hive_boxes.dart';
import '../models/category.dart';

final categoriesBoxProvider = Provider<Box<CategoryRecord>>((ref) {
  return Hive.box<CategoryRecord>(categoriesBoxName);
});

class CategoriesNotifier extends StateNotifier<List<CategoryRecord>> {
  final Box<CategoryRecord> box;
  CategoriesNotifier(this.box) : super(box.values.toList());

  void _refresh() => state = box.values.toList();

  Future<void> add(CategoryRecord c) async {
    await box.put(c.id, c);
    _refresh();
  }

  Future<void> rename(String id, String newName) async {
    final existing = box.get(id);
    if (existing == null) return;
    await box.put(
      id,
      CategoryRecord(
        id: existing.id,
        name: newName,
        kind: existing.kind,
        iconName: existing.iconName,
        colorHex: existing.colorHex,
        isCustom: existing.isCustom,
      ),
    );
    _refresh();
  }

  Future<void> delete(String id) async {
    await box.delete(id);
    _refresh();
  }
}

final categoriesProvider = StateNotifierProvider<CategoriesNotifier, List<CategoryRecord>>((ref) {
  return CategoriesNotifier(ref.watch(categoriesBoxProvider));
});
