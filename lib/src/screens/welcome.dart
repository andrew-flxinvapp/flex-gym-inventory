import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../widgets/layouts/app_screen.dart';
import '../widgets/layouts/onboarding_bottom_action_layout.dart';
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
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: const OnboardingLogoAppBar(
        showBackArrow: true,
        theme: OnboardingAppBarTheme.dark,
      ),
      body: AppScreen(
        useGradient: true,
        safeArea: true,
        lightSystemUi: true,
        child: OnboardingBottomActionLayout(
          content: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                Image.asset(
                  'lib/assets/images/new_welcome.png',
                  height: 325,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                Text(
                  'Meet Flex Rackley!',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppTheme.darkTextPrimary,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Your gym's behind-the-scenes MVP!",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.darkTextPrimary,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Every gym needs someone keeping things running smoothly. From managing equipment to keeping an eye on security, Flex Rackley wears a few hats around here.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.2,
                    color: AppTheme.darkTextPrimary,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "You handle the heavy lifting. He's got the rest covered.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.2,
                    color: AppTheme.darkTextPrimary,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
          action: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightBackground,
                foregroundColor: AppTheme.lightTextPrimary,
                minimumSize: const Size(0, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppTheme.darkBackground),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.socialProof);
              },
              child: Text(
                'Continue',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.lightTextPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
