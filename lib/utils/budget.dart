int budgetPercent(double spent, double budget) {
  if (budget <= 0) return 0;
  final pct = (spent / budget * 100).round();
  return pct.clamp(0, 100);
}
