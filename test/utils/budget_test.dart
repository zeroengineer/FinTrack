import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/utils/budget.dart';

void main() {
  test('computes rounded percentage of spent over budget', () {
    expect(budgetPercent(27440, 50000), 55);
  });

  test('clamps to 100 when spending exceeds budget', () {
    expect(budgetPercent(60000, 50000), 100);
  });

  test('returns 0 when budget is zero or negative', () {
    expect(budgetPercent(100, 0), 0);
    expect(budgetPercent(100, -10), 0);
  });
}
