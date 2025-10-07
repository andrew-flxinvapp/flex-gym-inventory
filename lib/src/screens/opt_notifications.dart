import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/onboarding_topappbar.dart';
import 'package:flex_gym_inventory/routes/routes.dart';

class OptNotificationsScreen extends StatefulWidget {
  const OptNotificationsScreen({super.key});

  @override
  State<OptNotificationsScreen> createState() => _OptNotificationsScreenState();
}

class _OptNotificationsScreenState extends State<OptNotificationsScreen> {
  bool _allowNotifications = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _allowNotifications = prefs.getBool('allow_notifications') ?? false;
    });
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
                      setState(() {
                        _allowNotifications = value;
                      });
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('allow_notifications', value);
                    },
                    // activeColor: AppTheme.primary,
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

