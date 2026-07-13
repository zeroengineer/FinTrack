import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/utils/currency.dart';

void main() {
  test('groups whole numbers using Indian digit grouping', () {
    expect(formatInr(320), '₹320');
    expect(formatInr(70000), '₹70,000');
    expect(formatInr(123456), '₹1,23,456');
    expect(formatInr(1499), '₹1,499');
  });

  test('keeps up to 2 decimal places when present', () {
    expect(formatInr(320.5), '₹320.50');
  });

  test('handles negative amounts', () {
    expect(formatInr(-500), '-₹500');
  });

  test('handles zero', () {
    expect(formatInr(0), '₹0');
  });
}
