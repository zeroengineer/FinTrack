import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../providers/app_state.dart';
import '../../providers/categories_provider.dart';
import '../../providers/pin_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/transactions_provider.dart';
import '../../services/export_service.dart';
import '../../services/reminder_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/csv_export.dart';
import '../../utils/currency.dart';
import '../about/about_screen.dart';
import '../categories/categories_screen.dart';
import '../pin/pin_setup_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final categoryCount = ref.watch(categoriesProvider).length;
    final palette = context.palette;

    Future<void> toggleReminders(bool enable) async {
      if (enable) {
        final granted = await ref.read(reminderServiceProvider).requestPermission();
        if (!granted) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification permission denied')));
          }
          return;
        }
        await ref.read(reminderServiceProvider).scheduleDailyReminder(settings.reminderMinutesSinceMidnight);
      } else {
        await ref.read(reminderServiceProvider).cancelReminder();
      }
      await ref.read(settingsProvider.notifier).setRemindersEnabled(enable);
    }

    Future<void> exportData() async {
      final txns = ref.read(transactionsProvider);
      final categoriesById = ref.read(categoriesByIdProvider);
      final csv = transactionsToCsv(txns, categoriesById);
      try {
        await ref.read(exportServiceProvider).shareCsv(csv, 'fintrack_export.csv');
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not export data')));
        }
      }
    }

    Future<void> togglePinLock(bool enable) async {
      if (enable) {
        await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PinSetupScreen()));
        return;
      }
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Turn off PIN Lock?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Turn off')),
          ],
        ),
      );
      if (confirmed == true) {
        await ref.read(pinRepositoryProvider).clearPin();
        await ref.read(settingsProvider.notifier).setPinLockEnabled(false);
      }
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text('Profile', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.6)),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: palette.surface, border: Border.all(color: palette.border), borderRadius: BorderRadius.circular(24)),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: const LinearGradient(colors: [AppColors.accent, Color(0xFF1E40AF)])),
                  alignment: Alignment.center,
                  child: Text(settings.userName.isEmpty ? '?' : settings.userName[0].toUpperCase(), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
                const SizedBox(width: 16),
                Expanded(child: Text(settings.userName, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800))),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _InfoCard(label: 'Monthly Salary', value: formatInr(settings.monthlySalary))),
              const SizedBox(width: 12),
              Expanded(child: _InfoCard(label: 'Default Budget', value: formatInr(settings.monthlyBudget))),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 24, 4, 10),
            child: Text('PREFERENCES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: palette.textTertiary, letterSpacing: 0.8)),
          ),
          Container(
            decoration: BoxDecoration(color: palette.surface, border: Border.all(color: palette.border), borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                _PrefRow(
                  icon: Symbols.sell,
                  color: const Color(0xFFF59E0B),
                  label: 'Categories',
                  trailing: Text('$categoryCount'),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CategoriesScreen())),
                ),
                _PrefRow(
                  icon: Symbols.notifications,
                  color: const Color(0xFF3B82F6),
                  label: 'Reminder Settings',
                  trailing: Switch(value: settings.remindersEnabled, onChanged: toggleReminders),
                  onTap: () => toggleReminders(!settings.remindersEnabled),
                ),
                _PrefRow(
                  icon: Symbols.ios_share,
                  color: AppColors.success,
                  label: 'Export Data',
                  trailing: const Text('CSV'),
                  onTap: exportData,
                ),
                _PrefRow(
                  icon: Symbols.cloud_sync,
                  color: const Color(0xFF06B6D4),
                  label: 'Backup & Restore',
                  trailing: const SizedBox.shrink(),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon'))),
                ),
                _PrefRow(
                  icon: Symbols.dark_mode,
                  color: const Color(0xFF8B5CF6),
                  label: 'Dark Mode',
                  trailing: Switch(value: settings.darkMode, onChanged: (v) => ref.read(settingsProvider.notifier).setDarkMode(v)),
                  onTap: () => ref.read(settingsProvider.notifier).setDarkMode(!settings.darkMode),
                ),
                _PrefRow(
                  icon: Symbols.lock,
                  color: AppColors.danger,
                  label: 'PIN Lock',
                  trailing: Switch(value: settings.pinLockEnabled, onChanged: togglePinLock),
                  onTap: () => togglePinLock(!settings.pinLockEnabled),
                ),
                _PrefRow(
                  icon: Symbols.info,
                  color: palette.textSecondary,
                  label: 'About',
                  trailing: const SizedBox.shrink(),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AboutScreen())),
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger)),
              icon: const Icon(Symbols.logout),
              label: const Text('Log Out'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label, value;
  const _InfoCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: palette.surface, border: Border.all(color: palette.border), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: palette.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _PrefRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final Widget trailing;
  final VoidCallback onTap;
  final bool isLast;
  const _PrefRow({required this.icon, required this.color, required this.label, required this.trailing, required this.onTap, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: palette.border))),
        child: Row(
          children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(11)), child: Icon(icon, size: 20, color: color)),
            const SizedBox(width: 15),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
            trailing,
          ],
        ),
      ),
    );
  }
}
