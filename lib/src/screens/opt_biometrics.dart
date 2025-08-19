import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/onboarding_topappbar.dart';
import 'package:flex_gym_inventory/routes/routes.dart';

class OptBiometricsScreen extends StatefulWidget {
  const OptBiometricsScreen({super.key});

  @override
  State<OptBiometricsScreen> createState() => _OptBiometricsScreenState();
}

class _OptBiometricsScreenState extends State<OptBiometricsScreen> {
  bool _biometricsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: const OnboardingLogoAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Changed from center to start
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32), // Added controlled top spacing
            Text(
              'Enable Biometrics?',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: AppTheme.lightTextPrimary,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Image.asset(
              'lib/assets/images/biometrics.png',
              height: 350,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Text(
              'Would you like to enable facial or fingerprint recognition for the future?',
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
                  'Enable biometrics',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTextPrimary,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(width: 16),
                CupertinoSwitch(
                  value: _biometricsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _biometricsEnabled = value;
                    });
                  },
                  // activeColor: AppTheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 40),
            PrimaryButton(
              label: 'Continue',
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.optNotifications);
              },
            ),
          ],
        ),
      ),
    );
  }
}
