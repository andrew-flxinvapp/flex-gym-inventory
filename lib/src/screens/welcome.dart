import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/onboarding_topappbar.dart';
import 'package:flex_gym_inventory/routes/routes.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

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
                'Meet Flex Rackley!',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppTheme.lightTextPrimary,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Your gym's strongest sidekick!",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTextPrimary,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Image.asset(
                'lib/assets/images/hello.png',
                height: 325,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              Text(
                'While you focus on the gains, Flex handles the gear. He keeps your equipment organized, tracks upgrades, and remembers what you need so you dont have to.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.2,
                  color: AppTheme.lightTextPrimary,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 50),
              PrimaryButton(
                label: 'Continue',
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.socialProof);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}