import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/onboarding_topappbar.dart';

class OnboardingCompleteScreen extends StatefulWidget {
  const OnboardingCompleteScreen({super.key});

  @override
  State<OnboardingCompleteScreen> createState() => _OnboardingCompleteScreenState();
}

class _OnboardingCompleteScreenState extends State<OnboardingCompleteScreen> {

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
              'Onboarding Complete!',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: AppTheme.lightTextPrimary,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Image.asset(
              'lib/assets/images/celebrate.png',
              height: 325,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Text(
              'You completed onboarding! The button below will take you to your Dashboard!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.2,
                color: AppTheme.lightTextPrimary,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 82),
            PrimaryButton(
              label: 'To Dashboard',
              onPressed: () {
                Navigator.of(context).pushNamed('/dashboard');
              },
            ),
          ],
        ),
      ),
    );
  }
}