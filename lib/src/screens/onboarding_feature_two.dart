import 'package:flex_gym_inventory/theme/app_theme.dart';
import 'package:flutter/material.dart';
import '../widgets/onboarding_topappbar.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/layouts/app_screen.dart';
import '../widgets/layouts/onboarding_bottom_action_layout.dart';
import 'package:flex_gym_inventory/routes/routes.dart';

class OnboardingFeatureTwoScreen extends StatelessWidget {
  const OnboardingFeatureTwoScreen({super.key});

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
        safeArea: false,
        lightSystemUi: true,
        child: OnboardingBottomActionLayout(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                child: Text(
                  'Track wishlists and upgrades',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color:
                        AppTheme.darkTextPrimary, // AppTheme.lightTextPrimary
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                child: Text(
                  'Save the equipment you want and plan your next purchase.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color:
                        AppTheme.darkTextPrimary, // AppTheme.lightTextPrimary
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 350,
                height: 350,
                child: Image.asset(
                  'lib/assets/images/feature_2.png',
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          action: PrimaryButton(
            label: 'Continue',
            variant: PrimaryButtonVariant.dark,
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.welcome);
            },
          ),
        ),
      ),
    );
  }
}
