import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:uuid/uuid.dart';
import '../../models/transaction.dart';
import '../../models/txn_kind.dart';
import '../../providers/app_state.dart';
import '../../providers/categories_provider.dart';
import '../../providers/transactions_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency.dart';
import '../../widgets/category_icon_avatar.dart';

const _uuid = Uuid();
const _keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0', 'back'];

class AddTransactionScreen extends ConsumerWidget {
  const AddTransactionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(addTxnDraftProvider);
    final notifier = ref.read(addTxnDraftProvider.notifier);
    final allCategories = ref.watch(categoriesProvider);
    final categories = allCategories.where((c) => c.kind == draft.kind).toList();
    final palette = context.palette;

    final parts = draft.amount.split('.');
    final wholeDisplay = groupIndianDigits(parts.first.isEmpty ? '0' : parts.first);
    final amountDisplay = '₹$wholeDisplay${parts.length > 1 ? '.${parts[1]}' : ''}';

    void save() {
      final amount = double.tryParse(draft.amount) ?? 0;
      if (amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter an amount first')));
        return;
      }
      final categoryId = draft.categoryId ?? (draft.kind == TxnKind.income ? 'salary' : 'food');
      final txn = TransactionRecord(
        id: draft.editingId ?? _uuid.v4(),
        kind: draft.kind,
        categoryId: categoryId,
        note: draft.note.isEmpty ? categoryId : draft.note,
        amount: amount,
        date: DateTime.now(),
      );
      if (draft.editingId != null) {
        ref.read(transactionsProvider.notifier).update(txn);
      } else {
        ref.read(transactionsProvider.notifier).add(txn);
      }
      notifier.reset();
      ref.read(currentTabProvider.notifier).state = AppTab.transactions;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(draft.kind == TxnKind.income ? 'Income added' : 'Expense added')),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => ref.read(currentTabProvider.notifier).state = AppTab.home,
                  icon: const Icon(Symbols.arrow_back),
                ),
                const Text('Add Transaction', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              ],
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 14),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(color: palette.surface, border: Border.all(color: palette.border), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Expanded(child: _SegButton(label: 'Expense', icon: Symbols.south_west, active: draft.kind == TxnKind.expense, onTap: () => notifier.setKind(TxnKind.expense))),
                  Expanded(child: _SegButton(label: 'Income', icon: Symbols.north_east, active: draft.kind == TxnKind.income, onTap: () => notifier.setKind(TxnKind.income))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 26),
              child: Center(
                child: Column(
                  children: [
                    Text(draft.kind == TxnKind.income ? 'Income amount' : 'Expense amount', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: palette.textSecondary)),
                    const SizedBox(height: 8),
                    Text(amountDisplay, style: TextStyle(fontSize: 54, fontWeight: FontWeight.w800, letterSpacing: -2, color: draft.amount == '0' ? palette.textQuaternary : null)),
                  ],
                ),
              ),
            ),
            Text('CATEGORY', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: palette.textTertiary, letterSpacing: 0.6)),
            const SizedBox(height: 12),
            SizedBox(
              height: 84,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final c in categories)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () => notifier.setCategory(c.id),
                        child: SizedBox(
                          width: 68,
                          child: Column(
                            children: [
                              Opacity(
                                opacity: draft.categoryId == c.id ? 1 : 0.7,
                                child: CategoryIconAvatar(iconName: c.iconName, colorHex: c.colorHex, size: 48, iconSize: 25),
                              ),
                              const SizedBox(height: 8),
                              Flexible(
                                child: Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: draft.categoryId == c.id ? null : palette.textSecondary)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(color: palette.surface, border: Border.all(color: palette.border), borderRadius: BorderRadius.circular(20)),
              child: TextField(
                onChanged: notifier.setNote,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Symbols.notes),
                  hintText: 'Add a note (optional)',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                ),
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.4,
              children: [
                for (final k in _keys)
                  Material(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => notifier.pressKey(k),
                      child: Center(
                        child: k == 'back'
                            ? const Icon(Symbols.backspace, size: 26)
                            : Text(k, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton.icon(
                onPressed: save,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                icon: const Icon(Symbols.check_circle, color: Colors.white),
                label: const Text('Save Transaction', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _SegButton({required this.label, required this.icon, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.accent : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 19, color: active ? Colors.white : context.palette.textSecondary),
              const SizedBox(width: 7),
              Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: active ? Colors.white : context.palette.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
