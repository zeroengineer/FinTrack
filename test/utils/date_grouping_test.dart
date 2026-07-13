import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/utils/date_grouping.dart';

void main() {
  final now = DateTime(2026, 7, 8, 15, 0);

  test('same calendar day as now is "Today"', () {
    expect(dayGroupLabel(DateTime(2026, 7, 8, 9, 10), now), 'Today');
  });

  test('one calendar day before now is "Yesterday"', () {
    expect(dayGroupLabel(DateTime(2026, 7, 7, 23, 59), now), 'Yesterday');
  });

  test('older dates use a "MMM d" label', () {
    expect(dayGroupLabel(DateTime(2026, 7, 5, 11, 20), now), 'Jul 5');
  });
}
