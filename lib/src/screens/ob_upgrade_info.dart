import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../widgets/layouts/app_screen.dart';
import '../../routes/routes.dart';
import '../widgets/cards/plan_comparison_card.dart';
import '../widgets/buttons/primary_button.dart';

class OnboardingUpgradeInfo extends StatelessWidget {
  const OnboardingUpgradeInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AppScreen(
          useGradient: true,
          lightSystemUi: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Pro Overview',
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(color: AppTheme.darkTextPrimary),
                    ),
                    TextButton(
                      onPressed:
                          () =>
                              Navigator.pushNamed(context, AppRoutes.complete),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.darkTextPrimary,
                        textStyle: Theme.of(context).textTheme.bodySmall,
                      ),
                      child: const Text('Skip'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Image.asset(
                            'lib/assets/images/flex_pro.png',
                            height: 160,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Get more out of Flex Gym Inventory',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(color: AppTheme.darkTextPrimary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Unlock unlimited everything, plus powerful tools to manage your gym with ease.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.darkTextPrimary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        const PlanComparisonCard(),
                        const SizedBox(height: 20),
                        PrimaryButton(
                          label: 'View Plans',
                          onPressed:
                              () => Navigator.pushNamed(
                                context,
                                AppRoutes.proPurchase,
                                arguments: true,
                              ),
                          variant: PrimaryButtonVariant.dark,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
