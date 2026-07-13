String formatInr(num amount) {
  final isNegative = amount < 0;
  final abs = amount.abs();
  final wholePart = abs.truncate();
  final decimalPart = abs - wholePart;
  final grouped = groupIndianDigits(wholePart.toString());
  final decimalStr = decimalPart > 0
      ? '.${(decimalPart * 100).round().toString().padLeft(2, '0')}'
      : '';
  return '${isNegative ? '-' : ''}₹$grouped$decimalStr';
}

String groupIndianDigits(String digits) {
  if (digits.length <= 3) return digits;
  final last3 = digits.substring(digits.length - 3);
  final parts = <String>[];
  var remaining = digits.substring(0, digits.length - 3);
  while (remaining.length > 2) {
    parts.insert(0, remaining.substring(remaining.length - 2));
    remaining = remaining.substring(0, remaining.length - 2);
  }
  if (remaining.isNotEmpty) parts.insert(0, remaining);
  return '${parts.join(',')},$last3';
}
