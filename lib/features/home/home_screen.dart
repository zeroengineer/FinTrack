import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../models/txn_kind.dart';
import '../../providers/app_state.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency.dart';
import '../../widgets/category_icon_avatar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(homeSummaryProvider);
    final budgetPct = ref.watch(budgetPercentProvider);
    final recent = ref.watch(recentTransactionsProvider);
    final categoriesById = ref.watch(categoriesByIdProvider);
    final settings = ref.watch(settingsProvider);
    final palette = context.palette;

    void goToAdd(TxnKind kind) {
      ref.read(addTxnDraftProvider.notifier).reset(kind: kind);
      ref.read(currentTabProvider.notifier).state = AppTab.add;
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Good Morning', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: palette.textSecondary)),
                      const SizedBox(height: 2),
                      Text('${settings.userName} 👋', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.4)),
                    ],
                  ),
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(color: palette.surface, shape: BoxShape.circle, border: Border.all(color: palette.border)),
                    child: Stack(
                      children: [
                        Center(child: Icon(Symbols.notifications, size: 24, color: palette.textSecondary)),
                        Positioned(
                          top: 11,
                          right: 12,
                          child: Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.danger, shape: BoxShape.circle, border: Border.all(color: palette.surface, width: 2))),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _BalanceHero(balance: summary.balance, income: summary.income, expense: summary.expense, savings: summary.savings),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: _QuickAction(label: 'Add Expense', icon: Symbols.remove, color: AppColors.danger, onTap: () => goToAdd(TxnKind.expense))),
                const SizedBox(width: 12),
                Expanded(child: _QuickAction(label: 'Add Income', icon: Symbols.add, color: AppColors.success, onTap: () => goToAdd(TxnKind.income))),
              ],
            ),
            const SizedBox(height: 18),
            _BudgetCard(budgetLabel: formatInr(settings.monthlyBudget), spent: summary.expense, budget: settings.monthlyBudget, pct: budgetPct),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Transactions', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                TextButton(
                  onPressed: () => ref.read(currentTabProvider.notifier).state = AppTab.transactions,
                  child: const Text('See all', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.accent)),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(color: palette.surface, border: Border.all(color: palette.border), borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: recent.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: Text('No transactions yet', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: palette.textSecondary))),
                    )
                  : Column(
                      children: [
                        for (final t in recent)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                            child: Row(
                              children: [
                                CategoryIconAvatar(
                                  iconName: categoriesById[t.categoryId]?.iconName ?? 'category',
                                  colorHex: categoriesById[t.categoryId]?.colorHex ?? '#94A3B8',
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(categoriesById[t.categoryId]?.name ?? t.categoryId, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                      Text(t.note, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: palette.textSecondary)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${t.kind == TxnKind.income ? '+' : '−'}${formatInr(t.amount)}',
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: t.kind == TxnKind.income ? AppColors.success : null),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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

class _BalanceHero extends StatelessWidget {
  final double balance, income, expense, savings;
  const _BalanceHero({required this.balance, required this.income, required this.expense, required this.savings});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.accent, Color(0xFF1E40AF)]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Available Balance', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white70)),
          const SizedBox(height: 6),
          Text(formatInr(balance), style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w800, letterSpacing: -1.5, color: Colors.white)),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(child: _HeroTile(label: 'Income', value: formatInr(income), icon: Symbols.arrow_downward)),
              const SizedBox(width: 10),
              Expanded(child: _HeroTile(label: 'Expenses', value: formatInr(expense), icon: Symbols.arrow_upward)),
              const SizedBox(width: 10),
              Expanded(child: _HeroTile(label: 'Savings', value: formatInr(savings), icon: Symbols.savings)),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroTile extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _HeroTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 13),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, size: 15, color: Colors.white70), const SizedBox(width: 5), Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white70))]),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: palette.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: palette.border)),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(11)),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 10),
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final String budgetLabel;
  final double spent, budget;
  final int pct;
  const _BudgetCard({required this.budgetLabel, required this.spent, required this.budget, required this.pct});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: palette.surface, border: Border.all(color: palette.border), borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Symbols.account_balance_wallet, size: 22, color: AppColors.accent),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Monthly Budget', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      Text('$budgetLabel limit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: palette.textSecondary)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(20)),
                child: Text('$pct% used', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accent)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (pct / 100).clamp(0, 1),
              minHeight: 12,
              backgroundColor: palette.surfaceAlt,
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Spent', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: palette.textSecondary)),
                  Text(formatInr(spent), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Remaining', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: palette.textSecondary)),
                  Text(formatInr(budget - spent), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.success)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
