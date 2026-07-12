import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finance_tracker/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  test('buildAppTheme(dark) carries the dark AppPalette extension', () {
    final theme = buildAppTheme(Brightness.dark);
    expect(theme.brightness, Brightness.dark);
    expect(theme.extension<AppPalette>(), AppPalette.dark);
  });

  test('buildAppTheme(light) carries the light AppPalette extension', () {
    final theme = buildAppTheme(Brightness.light);
    expect(theme.brightness, Brightness.light);
    expect(theme.extension<AppPalette>(), AppPalette.light);
  });

  test('AppPalette.lerp with a non-AppPalette extension returns this unchanged', () {
    expect(AppPalette.dark.lerp(null, 0.5), AppPalette.dark);
  });
}
