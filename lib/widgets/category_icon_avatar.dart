import 'package:flutter/material.dart';
import '../utils/color_utils.dart';
import '../utils/icon_lookup.dart';

class CategoryIconAvatar extends StatelessWidget {
  final String iconName;
  final String colorHex;
  final double size;
  final double iconSize;

  const CategoryIconAvatar({
    super.key,
    required this.iconName,
    required this.colorHex,
    this.size = 44,
    this.iconSize = 23,
  });

  @override
  Widget build(BuildContext context) {
    final color = colorFromHex(colorHex);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      alignment: Alignment.center,
      child: Icon(symbolFor(iconName), size: iconSize, color: color),
    );
  }
}
