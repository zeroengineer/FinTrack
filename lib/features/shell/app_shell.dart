import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../add_transaction/add_transaction_screen.dart';
import '../analytics/analytics_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../transactions/transactions_screen.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(currentTabProvider);
    return Scaffold(
      body: IndexedStack(
        index: AppTab.values.indexOf(tab),
        children: const [
          HomeScreen(),
          TransactionsScreen(),
          AddTransactionScreen(),
          AnalyticsScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _BottomNav(current: tab),
    );
  }
}

class _BottomNav extends ConsumerWidget {
  final AppTab current;
  const _BottomNav({required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;

    Widget navItem(AppTab tab, IconData icon, String label) {
      final active = tab == current;
      return Expanded(
        child: InkWell(
          onTap: () => ref.read(currentTabProvider.notifier).state = tab,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 25, color: active ? AppColors.accent : palette.textTertiary),
                const SizedBox(height: 5),
                Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: active ? AppColors.accent : palette.textTertiary)),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      height: 96,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      decoration: BoxDecoration(color: palette.surface.withOpacity(0.9), border: Border(top: BorderSide(color: palette.border))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          navItem(AppTab.home, Symbols.home, 'Home'),
          navItem(AppTab.transactions, Symbols.receipt_long, 'Transactions'),
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: () => ref.read(currentTabProvider.notifier).state = AppTab.add,
                // Raised above the bar; Container forbids negative margins,
                // so translate instead.
                child: Transform.translate(
                  offset: const Offset(0, -24),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [AppColors.accent, Color(0xFF1E40AF)])),
                    child: const Icon(Symbols.add, color: Colors.white, size: 32),
                  ),
                ),
              ),
            ),
          ),
          navItem(AppTab.analytics, Symbols.bar_chart_4_bars, 'Analytics'),
          navItem(AppTab.profile, Symbols.person, 'Profile'),
        ],
      ),
    );
  }
}
