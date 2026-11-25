import 'package:flutter/material.dart';
import '../widgets/onboarding_topappbar.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/layouts/app_screen.dart';
import '../widgets/layouts/onboarding_feature_layout.dart';
import 'package:flex_gym_inventory/routes/routes.dart';

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
        child: OnboardingFeatureLayout(
          title: 'Manage all of your gym equipment',
          description:
              'Keep track of all your bars, plates, machines, and accessories all in one place.',
          mockupAsset: 'lib/assets/images/gym_detail_mock.png',
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
