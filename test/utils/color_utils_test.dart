import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/utils/color_utils.dart';

void main() {
  test('parses a #RRGGBB hex string to an opaque Color', () {
    expect(colorFromHex('#F59E0B'), const Color(0xFFF59E0B));
    expect(colorFromHex('2563EB'), const Color(0xFF2563EB));
  });
}
