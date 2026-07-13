import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

abstract class ReminderService {
  Future<void> init();
  Future<bool> requestPermission();
  Future<void> scheduleDailyReminder(int minutesSinceMidnight);
  Future<void> cancelReminder();
}

class LocalNotificationsReminderService implements ReminderService {
  static const _reminderNotificationId = 1001;
  final FlutterLocalNotificationsPlugin plugin;
  LocalNotificationsReminderService(this.plugin);

  @override
  Future<void> init() async {
    tzdata.initializeTimeZones();
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await plugin.initialize(const InitializationSettings(android: androidInit, iOS: iosInit));
  }

  @override
  Future<bool> requestPermission() async {
    final androidImpl = plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final iosImpl = plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    final androidGranted = await androidImpl?.requestNotificationsPermission() ?? true;
    final iosGranted = await iosImpl?.requestPermissions(alert: true, badge: true, sound: true) ?? true;
    return androidGranted && iosGranted;
  }

  @override
  Future<void> scheduleDailyReminder(int minutesSinceMidnight) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, minutesSinceMidnight ~/ 60, minutesSinceMidnight % 60);
    if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));
    await plugin.zonedSchedule(
      _reminderNotificationId,
      'Log your expenses',
      "Don't forget to add today's transactions.",
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails('reminders', 'Reminders', importance: Importance.defaultImportance),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Future<void> cancelReminder() => plugin.cancel(_reminderNotificationId);
}

final reminderServiceProvider = Provider<ReminderService>((ref) {
  return LocalNotificationsReminderService(FlutterLocalNotificationsPlugin());
});
