import '../widgets/selectors/notifications_toggle.dart';
import 'package:flutter/material.dart';
import '../widgets/top_app_bar.dart';
import '../../theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '../repositories/onboarding_repository.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with WidgetsBindingObserver {
  bool allowNotifications = false;
  bool maintenanceReminders = false;
  bool newFeatureAnnouncements = false;
  bool weeklySummaries = false;
  bool appUpdates = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadNotificationPreference();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Re-check permission and server/prefs when the app returns to foreground.
      _loadNotificationPreference();
    }
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();

    // Prefer system permission as source-of-truth when possible.
    try {
      final status = await Permission.notification.status;
      // system permission status checked
      if (status.isGranted || status.isLimited) {
        allowNotifications = true;
      } else {
        // Try server-side value before falling back to local prefs.
        try {
          final repo = OnboardingRepository();
          final server = await repo.fetchNotificationsOn();
          if (server != null) {
            allowNotifications = server;
          } else {
            allowNotifications = prefs.getBool('allow_notifications') ?? false;
          }
        } catch (_) {
          allowNotifications = prefs.getBool('allow_notifications') ?? false;
        }
      }
    } catch (_) {
      allowNotifications = prefs.getBool('allow_notifications') ?? false;
    }

    // Load sub-option prefs
    maintenanceReminders = prefs.getBool('allow_notifications_maintenance') ?? false;
    newFeatureAnnouncements = prefs.getBool('allow_notifications_new_features') ?? false;
    weeklySummaries = prefs.getBool('allow_notifications_weekly') ?? false;
    appUpdates = prefs.getBool('allow_notifications_app_updates') ?? false;

    // loaded preferences and server state

    setState(() {});
  }

  Future<void> _updateNotificationPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    if (!value) {
      await prefs.setBool('allow_notifications', false);
      setState(() => allowNotifications = false);
      return;
    }

    // Request runtime notification permission when enabling notifications.
    final status = await Permission.notification.request();
    // permission request result available in `status`

    if (status.isGranted || status.isLimited) {
      await prefs.setBool('allow_notifications', true);
      setState(() => allowNotifications = true);
      try {
        final repo = OnboardingRepository();
        await repo.updateNotificationsOn(true);
        // updated server notificationsOn=true
      } catch (_) {}
    } else {
      // Persist the negative choice locally.
      await prefs.setBool('allow_notifications', false);
      setState(() => allowNotifications = false);

      try {
        final repo = OnboardingRepository();
        await repo.updateNotificationsOn(false);
        // updated server notificationsOn=false
      } catch (_) {}

      if (status.isPermanentlyDenied) {
        final open = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Enable notifications'),
            content: const Text(
              'Notifications are blocked. Open app settings to enable them.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );

        if (open == true) openAppSettings();
      }
    }
  }

  Future<void> _setMaintenance(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('allow_notifications_maintenance', v);
    setState(() => maintenanceReminders = v);
  }

  Future<void> _setNewFeatures(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('allow_notifications_new_features', v);
    setState(() => newFeatureAnnouncements = v);
  }

  Future<void> _setWeekly(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('allow_notifications_weekly', v);
    setState(() => weeklySummaries = v);
  }

  Future<void> _setAppUpdates(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('allow_notifications_app_updates', v);
    setState(() => appUpdates = v);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBar(
        title: 'Notifications',
        showBackArrow: true,
        showRightIcon: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Helpful reminders and updates',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Flex Gym Inventory can send you reminders to help you keep your equipment in top shape.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 24),
              NotificationsToggle(
                label: 'Allow Notifications?',
                initialValue: allowNotifications,
                onChanged: (val) {
                  _updateNotificationPreference(val);
                },
              ),
              const SizedBox(height: 32),
              Text(
                'Sub-options will be available in a future app update.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 12),
              AbsorbPointer(
                absorbing: true,
                child: Opacity(
                  opacity: 0.5,
                  child: Column(
                    children: [
                      NotificationsToggle(
                        label: 'Maintenance reminders',
                        initialValue: maintenanceReminders,
                        onChanged: (v) => _setMaintenance(v),
                      ),
                      const SizedBox(height: 8),
                      NotificationsToggle(
                        label: 'New feature announcements',
                        initialValue: newFeatureAnnouncements,
                        onChanged: (v) => _setNewFeatures(v),
                      ),
                      const SizedBox(height: 8),
                      NotificationsToggle(
                        label: 'Weekly usage summaries',
                        initialValue: weeklySummaries,
                        onChanged: (v) => _setWeekly(v),
                      ),
                      const SizedBox(height: 8),
                      NotificationsToggle(
                        label: 'App updates',
                        initialValue: appUpdates,
                        onChanged: (v) => _setAppUpdates(v),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
