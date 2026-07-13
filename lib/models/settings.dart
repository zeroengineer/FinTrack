import 'package:hive/hive.dart';

part 'settings.g.dart';

@HiveType(typeId: 3)
class SettingsRecord extends HiveObject {
  @HiveField(0)
  String userName;
  @HiveField(1)
  double monthlyBudget;
  @HiveField(2)
  double monthlySalary;
  @HiveField(3)
  bool darkMode;
  @HiveField(4)
  bool remindersEnabled;
  @HiveField(5)
  int reminderMinutesSinceMidnight;
  @HiveField(6)
  bool pinLockEnabled;
  @HiveField(7)
  bool onboardingComplete;

  SettingsRecord({
    this.userName = '',
    this.monthlyBudget = 0,
    this.monthlySalary = 0,
    this.darkMode = true,
    this.remindersEnabled = false,
    this.reminderMinutesSinceMidnight = 1200,
    this.pinLockEnabled = false,
    this.onboardingComplete = false,
  });
}
