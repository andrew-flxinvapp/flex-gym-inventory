import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_gym_inventory/providers/profile_data_provider.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/buttons/secondary_button.dart';
import '../widgets/onboarding_topappbar.dart';
import 'package:flex_gym_inventory/routes/routes.dart';
import '../widgets/layouts/app_screen.dart';

class OptNotificationsScreen extends ConsumerStatefulWidget {
  const OptNotificationsScreen({super.key});

  @override
  ConsumerState<OptNotificationsScreen> createState() => _OptNotificationsScreenState();
}

class _OptNotificationsScreenState extends ConsumerState<OptNotificationsScreen> {

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

        // Store the user's choice in the in-memory provider only.
        if (result.isGranted || result.isLimited) {
          ref.read(profileDataProvider.notifier).setNotificationsOn(true);
        } else {
          ref.read(profileDataProvider.notifier).setNotificationsOn(false);
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
      body: AppScreen(
        useGradient: true,
        safeArea: true,
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
                'lib/assets/images/new_notifications.png',
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
                  // Store the user's choice in the in-memory provider only.
                  ref.read(profileDataProvider.notifier).setNotificationsOn(false);
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
