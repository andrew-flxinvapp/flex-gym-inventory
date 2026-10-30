import 'package:flutter/material.dart';
import '../widgets/onboarding_topappbar.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/layouts/app_screen.dart';
import '../widgets/layouts/onboarding_bottom_action_layout.dart';
import 'package:flex_gym_inventory/routes/routes.dart';
import '/theme/app_theme.dart';

class OnboardingFeatureOneScreen extends StatelessWidget {
  const OnboardingFeatureOneScreen({super.key});

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
                  'Manage all of your gym equipment',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppTheme.darkTextPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                child: Text(
                  'Keep track of all your bars, plates, machines, and accessories all in one place.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.darkTextPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 350,
                height: 350,
                child: Image.asset(
                  'lib/assets/images/feature_1.png',
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          action: PrimaryButton(
            label: 'Continue',
            variant: PrimaryButtonVariant.dark,
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.onboardingFeatureTwo);
            },
          ),
        ),
      ),
    );
  }
}
