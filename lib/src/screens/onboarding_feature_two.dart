import 'package:flutter/material.dart';
import '../widgets/onboarding_topappbar.dart';
import '../widgets/buttons/primary_button.dart';
import 'package:flex_gym_inventory/routes/routes.dart';

class OnboardingFeatureTwoScreen extends StatelessWidget {
	const OnboardingFeatureTwoScreen({super.key});

	@override
		Widget build(BuildContext context) {
		return Scaffold(
			appBar: const OnboardingLogoAppBar(
				showBackArrow: true,
			),
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.center,
				children: [
					const SizedBox(height: 40),
					Padding(
						padding: const EdgeInsets.symmetric(horizontal: 24.0),
						child: Text(
							'Track wishlists and upgrades',
							textAlign: TextAlign.center,
							style: Theme.of(context).textTheme.displayMedium?.copyWith(
								color: const Color(0xFF023246), // AppTheme.lightTextPrimary
							),
						),
					),
					const SizedBox(height: 24),
					Padding(
						padding: const EdgeInsets.symmetric(horizontal: 24.0),
						child: Text(
							'Save the equipment you want and plan your next purchase.',
							textAlign: TextAlign.center,
							style: Theme.of(context).textTheme.bodyMedium?.copyWith(
								color: const Color(0xFF023246), // AppTheme.lightTextPrimary
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
											const SizedBox(height: 32),
											PrimaryButton(
												label: 'Continue',
												onPressed: () {
													Navigator.of(context).pushNamed(AppRoutes.welcome);
												},
											),
				],
			),
		);
		}
}
