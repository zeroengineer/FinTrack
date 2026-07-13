import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const accent = Color(0xFF2563EB);
  static const accent2 = Color(0xFF3B82F6);
  static const accentSoft = Color(0x292563EB); // ~16% alpha
  static const accentRing = Color(0x732563EB); // ~45% alpha
  static const success = Color(0xFF22C55E);
  static const danger = Color(0xFFEF4444);
  static const dangerStrong = Color(0xFFDC2626);

  static const darkBg = Color(0xFF06080D);
  static const darkSurface = Color(0xFF141A24);
  static const darkSurfaceAlt = Color(0xFF0A0E17);
  static const darkTextPrimary = Color(0xFFF8FAFC);
  static const darkTextSecondary = Color(0xFF94A3B8);
  static const darkTextTertiary = Color(0xFF64748B);
  static const darkTextQuaternary = Color(0xFF475569);
  static const darkBorder = Color(0x12FFFFFF);

  static const lightBg = Color(0xFFF8FAFC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceAlt = Color(0xFFF1F5F9);
  static const lightTextPrimary = Color(0xFF0F172A);
  static const lightTextSecondary = Color(0xFF64748B);
  static const lightTextTertiary = Color(0xFF94A3B8);
  static const lightTextQuaternary = Color(0xFFCBD5E1);
  static const lightBorder = Color(0x14000000);
}

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color surface;
  final Color surfaceAlt;
  final Color border;
  final Color textSecondary;
  final Color textTertiary;
  final Color textQuaternary;

  const AppPalette({
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.textSecondary,
    required this.textTertiary,
    required this.textQuaternary,
  });

  static const dark = AppPalette(
    surface: AppColors.darkSurface,
    surfaceAlt: AppColors.darkSurfaceAlt,
    border: AppColors.darkBorder,
    textSecondary: AppColors.darkTextSecondary,
    textTertiary: AppColors.darkTextTertiary,
    textQuaternary: AppColors.darkTextQuaternary,
  );

  static const light = AppPalette(
    surface: AppColors.lightSurface,
    surfaceAlt: AppColors.lightSurfaceAlt,
    border: AppColors.lightBorder,
    textSecondary: AppColors.lightTextSecondary,
    textTertiary: AppColors.lightTextTertiary,
    textQuaternary: AppColors.lightTextQuaternary,
  );

  @override
  AppPalette copyWith({
    Color? surface,
    Color? surfaceAlt,
    Color? border,
    Color? textSecondary,
    Color? textTertiary,
    Color? textQuaternary,
  }) {
    return AppPalette(
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      border: border ?? this.border,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textQuaternary: textQuaternary ?? this.textQuaternary,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      border: Color.lerp(border, other.border, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textQuaternary: Color.lerp(textQuaternary, other.textQuaternary, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppPalette &&
      surface == other.surface &&
      surfaceAlt == other.surfaceAlt &&
      border == other.border &&
      textSecondary == other.textSecondary &&
      textTertiary == other.textTertiary &&
      textQuaternary == other.textQuaternary;

  @override
  int get hashCode => Object.hash(
      surface, surfaceAlt, border, textSecondary, textTertiary, textQuaternary);
}

ThemeData buildAppTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final bg = isDark ? AppColors.darkBg : AppColors.lightBg;
  final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  final palette = isDark ? AppPalette.dark : AppPalette.light;
  final base = isDark ? ThemeData.dark() : ThemeData.light();

  return base.copyWith(
    brightness: brightness,
    scaffoldBackgroundColor: bg,
    primaryColor: AppColors.accent,
    colorScheme: base.colorScheme.copyWith(
      brightness: brightness,
      primary: AppColors.accent,
      onPrimary: Colors.white,
      secondary: AppColors.accent2,
      onSecondary: Colors.white,
      error: AppColors.danger,
      onError: Colors.white,
      surface: palette.surface,
      onSurface: textPrimary,
    ),
    textTheme: GoogleFonts.manropeTextTheme(base.textTheme).apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    ),
    extensions: [palette],
  );
}

extension AppPaletteX on BuildContext {
  AppPalette get palette {
    final theme = Theme.of(this);
    return theme.extension<AppPalette>() ??
        (theme.brightness == Brightness.dark ? AppPalette.dark : AppPalette.light);
  }
}
