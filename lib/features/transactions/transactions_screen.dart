import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../models/txn_kind.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import 'transaction_row.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grouped = ref.watch(groupedTransactionsProvider);
    final palette = context.palette;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('Transactions', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.6)),
            ),
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: palette.surface, border: Border.all(color: palette.border), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Icon(Symbols.search, size: 22, color: palette.textTertiary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
                      decoration: const InputDecoration(border: InputBorder.none, hintText: 'Search transactions'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const _FilterChipsRow(),
            const SizedBox(height: 14),
            Expanded(
              child: grouped.isEmpty
                  ? _EmptyState(palette: palette)
                  : ListView(
                      children: [
                        for (final entry in grouped) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(2, 18, 2, 10),
                            child: Text(entry.key.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: palette.textTertiary, letterSpacing: 0.8)),
                          ),
                          for (final t in entry.value) TransactionRow(txn: t),
                        ],
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 26),
                          child: Center(child: Text('Swipe a row left to delete, right to edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: palette.textQuaternary))),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppPalette palette;
  const _EmptyState({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(color: palette.surface, border: Border.all(color: palette.border), borderRadius: BorderRadius.circular(30)),
              child: Icon(Symbols.search_off, size: 46, color: palette.textQuaternary),
            ),
            const SizedBox(height: 22),
            const Text('No transactions found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('Try a different search term or clear your filters to see everything.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: palette.textSecondary, height: 1.5)),
          ],
        ),
      ),
    );
  }
}

class _FilterChipsRow extends ConsumerWidget {
  const _FilterChipsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final categoryId = ref.watch(selectedCategoryIdProvider);
    final kind = ref.watch(selectedKindFilterProvider);
    final categories = ref.watch(categoriesByIdProvider).values.toList();
    final palette = context.palette;

    Widget chip(String label, bool active, VoidCallback onTap) {
      return Padding(
        padding: const EdgeInsets.only(right: 9),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: active ? AppColors.accent.withValues(alpha: 0.16) : palette.surface,
              border: Border.all(color: active ? AppColors.accent : palette.border),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: active ? AppColors.accent : null)),
                const Icon(Icons.expand_more, size: 16),
              ],
            ),
          ),
        ),
      );
    }

    Future<void> pickMonth() async {
      final now = DateTime.now();
      final options = <DateTime?>[null, for (var i = 0; i < 6; i++) DateTime(now.year, now.month - i, 1)];
      final choice = await showModalBottomSheet<DateTime?>(
        context: context,
        builder: (_) => ListView(
          shrinkWrap: true,
          children: [
            for (final m in options)
              ListTile(
                title: Text(m == null ? 'All months' : '${m.month}/${m.year}'),
                onTap: () => Navigator.pop(context, m),
              ),
          ],
        ),
      );
      ref.read(selectedMonthProvider.notifier).state = choice;
    }

    Future<void> pickCategory() async {
      final choice = await showModalBottomSheet<String?>(
        context: context,
        builder: (_) => ListView(
          shrinkWrap: true,
          children: [
            ListTile(title: const Text('All Categories'), onTap: () => Navigator.pop(context)),
            for (final c in categories) ListTile(title: Text(c.name), onTap: () => Navigator.pop(context, c.id)),
          ],
        ),
      );
      ref.read(selectedCategoryIdProvider.notifier).state = choice;
    }

    Future<void> pickType() async {
      final choice = await showModalBottomSheet<int?>(
        context: context,
        builder: (_) => ListView(
          shrinkWrap: true,
          children: [
            ListTile(title: const Text('All Types'), onTap: () => Navigator.pop(context, -1)),
            ListTile(title: const Text('Income'), onTap: () => Navigator.pop(context, 1)),
            ListTile(title: const Text('Expense'), onTap: () => Navigator.pop(context, 0)),
          ],
        ),
      );
      if (choice == null) return;
      ref.read(selectedKindFilterProvider.notifier).state = choice == -1 ? null : TxnKind.values[choice];
    }

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          chip(month == null ? 'All Months' : '${month.month}/${month.year}', month != null, pickMonth),
          chip(categoryId == null ? 'All Categories' : (categories.where((c) => c.id == categoryId).isEmpty ? 'Category' : categories.firstWhere((c) => c.id == categoryId).name), categoryId != null, pickCategory),
          chip(kind == null ? 'All Types' : (kind == TxnKind.income ? 'Income' : 'Expense'), kind != null, pickType),
        ],
      ),
    );
  }
}
