import 'package:flutter/material.dart';

Color colorFromHex(String hex) {
  final cleaned = hex.replaceFirst('#', '');
  final value = int.parse(cleaned, radix: 16);
  return Color(0xFF000000 | value);
}
