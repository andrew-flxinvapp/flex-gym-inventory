import 'package:flutter/material.dart';
import '../widgets/onboarding_topappbar.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/layouts/app_screen.dart';
import '../widgets/layouts/onboarding_feature_layout.dart';
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
        child: OnboardingFeatureLayout(
          title: 'Track wishlists and upgrades',
          description:
              'Save the equipment you want and plan your next purchase.',
          mockupAsset: 'lib/assets/images/wishlist_mock.png',
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
