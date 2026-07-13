import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'data/hive_boxes.dart';
import 'services/reminder_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initHive();
  } catch (e) {
    runApp(_StartupErrorApp(error: e.toString()));
    return;
  }
  // Best-effort: reminders are an optional subsystem, and the plugin has no
  // implementation on some platforms (e.g. web) — never block app start.
  try {
    await LocalNotificationsReminderService(FlutterLocalNotificationsPlugin()).init();
  } catch (_) {}
  runApp(const ProviderScope(child: FinanceTrackerApp()));
}

class _StartupErrorApp extends StatelessWidget {
  final String error;
  const _StartupErrorApp({required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text('FinTrack failed to start', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(error, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: main, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
