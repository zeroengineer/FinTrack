import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/features/about/about_screen.dart';

void main() {
  testWidgets('shows the app name and version', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AboutScreen()));
    expect(find.text('FinTrack'), findsWidgets);
    expect(find.textContaining('2.4.0'), findsOneWidget);
  });
}
