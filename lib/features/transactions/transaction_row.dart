import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../models/transaction.dart';
import '../../models/txn_kind.dart';
import '../../providers/app_state.dart';
import '../../providers/transactions_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency.dart';
import '../../widgets/category_icon_avatar.dart';

class TransactionRow extends ConsumerWidget {
  final TransactionRecord txn;
  const TransactionRow({super.key, required this.txn});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesById = ref.watch(categoriesByIdProvider);
    final cat = categoriesById[txn.categoryId];
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Slidable(
        key: ValueKey(txn.id),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.28,
          children: [
            SlidableAction(
              onPressed: (_) {
                ref.read(addTxnDraftProvider.notifier).loadForEdit(txn);
                ref.read(currentTabProvider.notifier).state = AppTab.add;
              },
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
              borderRadius: BorderRadius.circular(20),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.28,
          children: [
            SlidableAction(
              onPressed: (_) => ref.read(transactionsProvider.notifier).delete(txn.id),
              backgroundColor: AppColors.dangerStrong,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
              borderRadius: BorderRadius.circular(20),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(color: palette.surface, border: Border.all(color: palette.border), borderRadius: BorderRadius.circular(20)),
          child: Row(
            children: [
              CategoryIconAvatar(iconName: cat?.iconName ?? 'category', colorHex: cat?.colorHex ?? '#94A3B8'),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cat?.name ?? txn.categoryId, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    Text(txn.note, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: palette.textSecondary)),
                  ],
                ),
              ),
              Text(
                '${txn.kind == TxnKind.income ? '+' : '−'}${formatInr(txn.amount)}',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: txn.kind == TxnKind.income ? AppColors.success : null),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
