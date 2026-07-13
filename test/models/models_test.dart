import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/txn_kind.dart';
import 'package:finance_tracker/models/transaction.dart';
import 'package:finance_tracker/models/category.dart';
import 'package:finance_tracker/models/settings.dart';

void main() {
  test('TransactionRecord holds the fields it was constructed with', () {
    final t = TransactionRecord(
      id: '1',
      kind: TxnKind.expense,
      categoryId: 'food',
      note: 'Lunch',
      amount: 320,
      date: DateTime(2026, 7, 8),
    );
    expect(t.kind, TxnKind.expense);
    expect(t.categoryId, 'food');
    expect(t.amount, 320);
  });

  test('CategoryRecord defaults isCustom to false', () {
    final c = CategoryRecord(
      id: 'food',
      name: 'Food',
      kind: TxnKind.expense,
      iconName: 'restaurant',
      colorHex: '#F59E0B',
    );
    expect(c.isCustom, false);
  });

  test('SettingsRecord has no mock data — starts empty/false pre-onboarding', () {
    final s = SettingsRecord();
    expect(s.userName, '');
    expect(s.monthlyBudget, 0);
    expect(s.monthlySalary, 0);
    expect(s.darkMode, true);
    expect(s.pinLockEnabled, false);
    expect(s.onboardingComplete, false);
  });
}
