import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../providers/app_state.dart';
import '../../providers/transactions_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/color_utils.dart';
import '../../utils/currency.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAnyTransactions = ref.watch(transactionsProvider).isNotEmpty;
    final palette = context.palette;

    if (!hasAnyTransactions) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Symbols.bar_chart_4_bars, size: 46, color: palette.textQuaternary),
                const SizedBox(height: 16),
                const Text('No analytics yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text('Add a transaction to see your spending overview here.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: palette.textSecondary)),
              ],
            ),
          ),
        ),
      );
    }

    final summary = ref.watch(homeSummaryProvider);
    final breakdown = ref.watch(categoryBreakdownProvider);
    final topCats = ref.watch(topSpendingCategoriesProvider);
    final series = ref.watch(monthlySeriesProvider);
    final categoriesById = ref.watch(categoriesByIdProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('Analytics', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.6)),
            ),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Income vs Expense', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 180,
                    child: BarChart(
                      BarChartData(
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, meta) {
                                final i = v.toInt();
                                if (i < 0 || i >= series.length) return const SizedBox.shrink();
                                const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                                return Text(monthNames[series[i].month.month - 1], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600));
                              },
                            ),
                          ),
                        ),
                        barGroups: [
                          for (var i = 0; i < series.length; i++)
                            BarChartGroupData(x: i, barRods: [
                              BarChartRodData(toY: series[i].income, color: AppColors.accent, width: 8, borderRadius: BorderRadius.circular(4)),
                              BarChartRodData(toY: series[i].expense, color: const Color(0xFF475569), width: 8, borderRadius: BorderRadius.circular(4)),
                            ]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Category Breakdown', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 50,
                                sections: [
                                  for (final b in breakdown)
                                    PieChartSectionData(
                                      value: b.amount,
                                      color: colorFromHex(categoriesById[b.categoryId]?.colorHex ?? '#94A3B8'),
                                      showTitle: false,
                                      radius: 20,
                                    ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Total', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: palette.textSecondary)),
                                Text(formatInr(summary.expense), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          children: [
                            for (final b in breakdown)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 11),
                                child: Row(
                                  children: [
                                    Container(width: 10, height: 10, decoration: BoxDecoration(color: colorFromHex(categoriesById[b.categoryId]?.colorHex ?? '#94A3B8'), borderRadius: BorderRadius.circular(3))),
                                    const SizedBox(width: 9),
                                    Expanded(child: Text(categoriesById[b.categoryId]?.name ?? b.categoryId, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                                    Text('${b.percent.round()}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Top Spending Categories', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  for (final c in topCats)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(categoriesById[c.categoryId]?.name ?? c.categoryId, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                              Text(formatInr(c.amount), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: c.barFraction.clamp(0, 1),
                              minHeight: 8,
                              backgroundColor: palette.surfaceAlt,
                              valueColor: AlwaysStoppedAnimation(colorFromHex(categoriesById[c.categoryId]?.colorHex ?? '#94A3B8')),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Monthly Trend', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  Text('Savings over the last 6 months', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: palette.textSecondary)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 150,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, meta) {
                                final i = v.toInt();
                                if (i < 0 || i >= series.length) return const SizedBox.shrink();
                                const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                                return Text(monthNames[series[i].month.month - 1], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600));
                              },
                            ),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [for (var i = 0; i < series.length; i++) FlSpot(i.toDouble(), series[i].savings)],
                            isCurved: true,
                            color: AppColors.accent,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(show: true, color: AppColors.accent.withOpacity(0.2)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF16A34A), Color(0xFF065F46)]),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [Icon(Symbols.trending_up, size: 20, color: Colors.white), SizedBox(width: 8), Text('Total Savings This Month', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white))]),
                  const SizedBox(height: 8),
                  Text(formatInr(summary.savings), style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -1, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: palette.surface, border: Border.all(color: palette.border), borderRadius: BorderRadius.circular(24)),
      child: child,
    );
  }
}
