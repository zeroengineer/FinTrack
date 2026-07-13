import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../data/hive_boxes.dart';
import '../models/settings.dart';

final settingsBoxProvider = Provider<Box<SettingsRecord>>((ref) {
  return Hive.box<SettingsRecord>(settingsBoxName);
});

class SettingsNotifier extends StateNotifier<SettingsRecord> {
  final Box<SettingsRecord> box;
  SettingsNotifier(this.box) : super(box.get(settingsKey) ?? SettingsRecord());

  Future<void> _save(SettingsRecord next) async {
    await box.put(settingsKey, next);
    state = next;
  }

  Future<void> setUserName(String v) => _save(_copy(userName: v));
  Future<void> setMonthlyBudget(double v) => _save(_copy(monthlyBudget: v));
  Future<void> setMonthlySalary(double v) => _save(_copy(monthlySalary: v));
  Future<void> setDarkMode(bool v) => _save(_copy(darkMode: v));
  Future<void> setRemindersEnabled(bool v) => _save(_copy(remindersEnabled: v));
  Future<void> setReminderMinutes(int v) => _save(_copy(reminderMinutesSinceMidnight: v));
  Future<void> setPinLockEnabled(bool v) => _save(_copy(pinLockEnabled: v));

  Future<void> completeOnboarding({
    required String userName,
    required double monthlySalary,
    required double monthlyBudget,
  }) {
    return _save(_copy(
      userName: userName,
      monthlySalary: monthlySalary,
      monthlyBudget: monthlyBudget,
      onboardingComplete: true,
    ));
  }

  SettingsRecord _copy({
    String? userName,
    double? monthlyBudget,
    double? monthlySalary,
    bool? darkMode,
    bool? remindersEnabled,
    int? reminderMinutesSinceMidnight,
    bool? pinLockEnabled,
    bool? onboardingComplete,
  }) {
    return SettingsRecord(
      userName: userName ?? state.userName,
      monthlyBudget: monthlyBudget ?? state.monthlyBudget,
      monthlySalary: monthlySalary ?? state.monthlySalary,
      darkMode: darkMode ?? state.darkMode,
      remindersEnabled: remindersEnabled ?? state.remindersEnabled,
      reminderMinutesSinceMidnight: reminderMinutesSinceMidnight ?? state.reminderMinutesSinceMidnight,
      pinLockEnabled: pinLockEnabled ?? state.pinLockEnabled,
      onboardingComplete: onboardingComplete ?? state.onboardingComplete,
    );
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsRecord>((ref) {
  return SettingsNotifier(ref.watch(settingsBoxProvider));
});
