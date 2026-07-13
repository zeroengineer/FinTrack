import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/models/settings.dart';
import 'package:finance_tracker/providers/settings_provider.dart';
import 'package:finance_tracker/data/hive_boxes.dart';
import 'package:finance_tracker/features/onboarding/onboarding_flow.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(SettingsRecordAdapter());
    // In-memory box: widget tests run in a FakeAsync zone where real file
    // IO futures never complete, so a disk-backed box would hang forever.
    final box = await Hive.openBox<SettingsRecord>(settingsBoxName, bytes: Uint8List(0));
    await box.put(settingsKey, SettingsRecord());
  });

  tearDown(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  testWidgets('walking through all 3 steps completes onboarding with entered values', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: OnboardingFlow()),
      ),
    );

    // Step 1: Welcome
    await tester.tap(find.byKey(const Key('onboarding_get_started_button')));
    await tester.pumpAndSettle();

    // Step 2: Name
    await tester.enterText(find.byKey(const Key('onboarding_name_field')), 'Asha');
    await tester.tap(find.byKey(const Key('onboarding_name_next_button')));
    await tester.pumpAndSettle();

    // Step 3: Salary & budget
    await tester.enterText(find.byKey(const Key('onboarding_salary_field')), '60000');
    await tester.enterText(find.byKey(const Key('onboarding_budget_field')), '40000');
    await tester.tap(find.byKey(const Key('onboarding_finish_button')));
    await tester.pumpAndSettle();

    final settings = container.read(settingsProvider);
    expect(settings.userName, 'Asha');
    expect(settings.monthlySalary, 60000);
    expect(settings.monthlyBudget, 40000);
    expect(settings.onboardingComplete, true);
  });

  testWidgets('tapping Next on the name step with an empty name does not advance', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: OnboardingFlow()),
      ),
    );

    await tester.tap(find.byKey(const Key('onboarding_get_started_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('onboarding_name_next_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('onboarding_name_field')), findsOneWidget);
    expect(container.read(settingsProvider).onboardingComplete, false);
  });
}
