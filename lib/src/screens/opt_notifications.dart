import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../theme/app_theme.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/onboarding_topappbar.dart';
import 'package:flex_gym_inventory/routes/routes.dart';

class OptNotificationsScreen extends StatefulWidget {
  /// Optional test injection for Supabase client (avoids touching global
  /// `Supabase.instance` during widget tests).
  final dynamic supabaseClient;

  /// Optional injection for permission requester to make tests deterministic.
  final Future<PermissionStatus> Function()? permissionRequest;

  const OptNotificationsScreen({super.key, this.supabaseClient, this.permissionRequest});

  @override
  State<OptNotificationsScreen> createState() => _OptNotificationsScreenState();
}

class _OptNotificationsScreenState extends State<OptNotificationsScreen> {

  // whether notifications are allowed
  bool _allowNotifications = false;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _loadNotificationsPreference();
    _initLocalNotifications();
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosSettings = DarwinInitializationSettings();
    final settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    try {
      await _localNotifications.initialize(settings: settings);
    } catch (_) {
      // ignore initialization errors for now
    }
  }
  Future<void> _loadNotificationsPreference() async {
    final client = widget.supabaseClient ?? Supabase.instance.client;
    final user = client.auth.currentUser;

    if (user != null) {
      final value = (user.userMetadata?['notificationsOn'] as bool?) ?? false;

      setState(() {
        _allowNotifications = value;
      });
    }
  }

  Future<void> _saveNotificationsPreference() async {
    try {
      final client = widget.supabaseClient ?? Supabase.instance.client;
      await client.auth.updateUser(
        UserAttributes(
          data: {'notificationsOn': _allowNotifications},
        ),
      );
    } catch (e) {
      // ignore errors for now; could log or show a message
    }
  }

  Future<void> _requestPermissionAndSave(bool enable) async {
    if (!enable) {
      // user turned off notifications — persist and return
      setState(() => _allowNotifications = false);
      await _saveNotificationsPreference();
      return;
    }

    // Request runtime notification permission (Android 13+, iOS)
    final status = await (widget.permissionRequest?.call() ?? Permission.notification.request());

    if (status.isGranted) {
      setState(() => _allowNotifications = true);
      await _saveNotificationsPreference();
      // show a quick local test notification to confirm the setting
      try {
        await _showTestNotification();
      } catch (_) {
        // ignore; non-critical
      }
    } else {
      // Persist the negative choice
      setState(() => _allowNotifications = false);
      await _saveNotificationsPreference();

      if (status.isPermanentlyDenied) {
        // Offer user a path to app settings so they can enable later
        if (!mounted) return;
        final open = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Enable notifications'),
            content: const Text('Notifications are blocked. Open app settings to enable them.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Open Settings')),
            ],
          ),
        );

        if (open == true) {
          openAppSettings();
        }
      }
    }
  }

  Future<void> _showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Channel for test notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const platformDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _localNotifications.show(
      id: 0,
      title: 'Notifications enabled',
      body: 'You will receive updates and reminders.',
      notificationDetails: platformDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: const OnboardingLogoAppBar(
        showBackArrow: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // Changed from center to start
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32), // Added controlled top spacing
              Text(
                'Enable Notifications?',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppTheme.lightTextPrimary,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Image.asset(
                'lib/assets/images/notifications.png',
                height: 350,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              Text(
                'Would you like to enable notifications for future features and reminders?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.2,
                  color: AppTheme.lightTextPrimary,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Enable notifications',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTextPrimary,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(width: 16),
                  CupertinoSwitch(
                    value: _allowNotifications,
                    onChanged: (value) async {
                      await _requestPermissionAndSave(value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40),
              PrimaryButton(
                label: 'Continue',
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.onboardingFeatureOne);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

