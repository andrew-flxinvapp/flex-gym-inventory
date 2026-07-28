import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/buttons/secondary_button.dart';
import '../widgets/onboarding_topappbar.dart';
import 'package:flex_gym_inventory/routes/routes.dart';

class OptNotificationsScreen extends StatefulWidget {
  const OptNotificationsScreen({super.key});

  @override
  State<OptNotificationsScreen> createState() => _OptNotificationsScreenState();
}

class _OptNotificationsScreenState extends State<OptNotificationsScreen> {

  Future<void> _handleEnablePress() async {
    // Check current status first. The system dialog only appears when the
    // permission state is undetermined (first time). If it's already been
    // decided, show an explanatory dialog offering to open app settings.
    try {
      final status = await Permission.notification.status;

      if (status.isPermanentlyDenied) {
        // Show a brief rationale and offer to open app settings.
        if (!mounted) return;
        final open = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Notifications disabled'),
            content: const Text(
              'Notifications are disabled for this app. Open Settings to enable them.',
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

        if (open == true) {
          openAppSettings();
        }
      } else {
        // Request permission; on first run this will show the system dialog.
        final result = await Permission.notification.request();

        // Persist the user's choice locally so Settings reflects onboarding.
        try {
          final prefs = await SharedPreferences.getInstance();
          if (result.isGranted || result.isLimited) {
            await prefs.setBool('allow_notifications', true);
          } else {
            await prefs.setBool('allow_notifications', false);
          }
        } catch (_) {
          // ignore persistence errors
        }
      }
    } catch (_) {
      // ignore errors
    }

    if (!mounted) return;
    Navigator.of(context).pushNamed(AppRoutes.onboardingFeatureOne);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: const OnboardingLogoAppBar(showBackArrow: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
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
              const SizedBox(height: 40),
              PrimaryButton(
                label: 'Enable Notifications',
                onPressed: () async {
                  await _handleEnablePress();
                },
              ),
              const SizedBox(height: 16),
              SecondaryButton(
                label: 'Not Now',
                onPressed: () async {
                  try {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('allow_notifications', false);
                  } catch (_) {}

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
