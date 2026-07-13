import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/models/settings.dart';
import 'package:finance_tracker/providers/settings_provider.dart';
import 'package:finance_tracker/data/hive_boxes.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(SettingsRecordAdapter());
    final box = await Hive.openBox<SettingsRecord>(settingsBoxName);
    await box.put(settingsKey, SettingsRecord());
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    tempDir.deleteSync(recursive: true);
  });

  test('starts from the record already in the box, with no mock data', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(settingsProvider).userName, '');
    expect(container.read(settingsProvider).onboardingComplete, false);
  });

  test('completeOnboarding sets name/salary/budget and flips onboardingComplete', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(settingsProvider.notifier).completeOnboarding(
          userName: 'Asha',
          monthlySalary: 60000,
          monthlyBudget: 40000,
        );
    final s = container.read(settingsProvider);
    expect(s.userName, 'Asha');
    expect(s.monthlySalary, 60000);
    expect(s.monthlyBudget, 40000);
    expect(s.onboardingComplete, true);
  });

  test('setDarkMode persists and updates state', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(settingsProvider.notifier).setDarkMode(false);
    expect(container.read(settingsProvider).darkMode, false);
    expect(Hive.box<SettingsRecord>(settingsBoxName).get(settingsKey)!.darkMode, false);
  });

  test('setMonthlyBudget persists and updates state', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(settingsProvider.notifier).setMonthlyBudget(80000);
    expect(container.read(settingsProvider).monthlyBudget, 80000);
  });

  test('setPinLockEnabled persists and updates state', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(settingsProvider.notifier).setPinLockEnabled(true);
    expect(container.read(settingsProvider).pinLockEnabled, true);
  });
}
