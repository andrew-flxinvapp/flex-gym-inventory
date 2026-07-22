import 'package:flutter/material.dart';
import '../widgets/onboarding_topappbar.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_theme.dart';
import '../widgets/buttons/primary_button.dart';
import 'package:flex_gym_inventory/routes/routes.dart';

class SocialProofScreen extends StatelessWidget {
  const SocialProofScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: const OnboardingLogoAppBar(
        showBackArrow: true,
        theme: OnboardingAppBarTheme.dark,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.9, -0.62),
            radius: 1.6,
            focal: Alignment(0.9, -0.7),
            focalRadius: 0.001,
            colors: [
              Color(0xFF1F4F66), // 0%
              Color(0xFF023246), // 28%
              Color(0xFF010D1B), // 64%
              Color(0xFF000000), // 100%
            ],
            stops: [0.0, 0.3, 0.8, 1.0],
            transform: GradientRotation(0.25),
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            // Social proof block
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Trusted by gym owners everywhere',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppTheme.darkTextPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Rated 4.9 by early adopters',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.darkTextPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    for (int i = 0; i < 5; i++) ...[
                      Image.asset(AppIcons.star, width: 14, height: 14),
                      if (i < 4) const SizedBox(width: 4),
                    ],
                    const SizedBox(width: 8),
                    Text(
                      '10k+ ratings',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.darkTextPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppIcons.apple,
                      width: 18,
                      height: 18,
                      color: AppTheme.darkTextPrimary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'App Store',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.darkTextPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Testimonial block
            const SizedBox(height: 60),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    '"Flex Gym Inventory makes it so much easier to keep track of my home gym. I can see what I have at a glance and plan what to add next without digging through notes or spreadsheets."',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.darkTextPrimary,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Jordan M., Garage Gym Owner',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.darkTextPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Spacer(),
            PrimaryButton(
              label: 'Continue',
              variant: PrimaryButtonVariant.dark,
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.newOnboardingUpgrade);
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    ));
  }
}
