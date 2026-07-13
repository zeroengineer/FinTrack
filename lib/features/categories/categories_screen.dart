import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/category.dart';
import '../../models/txn_kind.dart';
import '../../providers/categories_provider.dart';
import '../../utils/icon_lookup.dart';
import '../../widgets/category_icon_avatar.dart';

const _uuid = Uuid();
const _palette = ['#F59E0B', '#3B82F6', '#EC4899', '#8B5CF6', '#F43F5E', '#22C55E', '#06B6D4', '#6366F1', '#F97316', '#94A3B8'];

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    Future<void> confirmDelete(CategoryRecord c) async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('Delete "${c.name}"?'),
          content: const Text('Existing transactions in this category will keep showing it by name.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Delete')),
          ],
        ),
      );
      if (confirmed == true) {
        await ref.read(categoriesProvider.notifier).delete(c.id);
      }
    }

    Future<void> rename(CategoryRecord c) async {
      final controller = TextEditingController(text: c.name);
      final newName = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Rename category'),
          content: TextField(controller: controller),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(dialogContext, controller.text.trim()), child: const Text('Save')),
          ],
        ),
      );
      if (newName != null && newName.isNotEmpty) {
        await ref.read(categoriesProvider.notifier).rename(c.id, newName);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: ListView(
        children: [
          for (final c in categories)
            ListTile(
              leading: CategoryIconAvatar(iconName: c.iconName, colorHex: c.colorHex, size: 36, iconSize: 20),
              title: Text(c.name),
              subtitle: Text(c.kind == TxnKind.expense ? 'Expense' : 'Income'),
              trailing: c.isCustom
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => rename(c)),
                        IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => confirmDelete(c)),
                      ],
                    )
                  : null,
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(context: context, builder: (_) => const _AddCategoryDialog()),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddCategoryDialog extends ConsumerStatefulWidget {
  const _AddCategoryDialog();

  @override
  ConsumerState<_AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends ConsumerState<_AddCategoryDialog> {
  final _nameController = TextEditingController();
  TxnKind _kind = TxnKind.expense;
  String _iconName = kIconLookup.keys.first;
  String _colorHex = _palette.first;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    await ref.read(categoriesProvider.notifier).add(CategoryRecord(
          id: _uuid.v4(),
          name: name,
          kind: _kind,
          iconName: _iconName,
          colorHex: _colorHex,
          isCustom: true,
        ));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add category'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(key: const Key('add_category_name_field'), controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 12),
            SegmentedButton<TxnKind>(
              segments: const [
                ButtonSegment(value: TxnKind.expense, label: Text('Expense')),
                ButtonSegment(value: TxnKind.income, label: Text('Income')),
              ],
              selected: {_kind},
              onSelectionChanged: (s) => setState(() => _kind = s.first),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                for (final name in kIconLookup.keys)
                  GestureDetector(
                    onTap: () => setState(() => _iconName = name),
                    child: CircleAvatar(
                      backgroundColor: _iconName == name ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2) : null,
                      child: Icon(kIconLookup[name]),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                for (final hex in _palette)
                  GestureDetector(
                    onTap: () => setState(() => _colorHex = hex),
                    child: CircleAvatar(
                      backgroundColor: Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16)),
                      child: _colorHex == hex ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(key: const Key('add_category_save_button'), onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
