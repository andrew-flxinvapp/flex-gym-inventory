import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../widgets/layouts/app_screen.dart';
import '../widgets/layouts/pro_overview_layout.dart';
import '../../routes/routes.dart';

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
          safeArea: true,
          lightSystemUi: true,
          child: ProOverviewLayout(
            headerAction: TextButton(
              onPressed:
                  () => Navigator.pushNamed(
                    context,
                    AppRoutes.complete,
                  ),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.darkTextPrimary,
                textStyle: Theme.of(context).textTheme.bodySmall,
              ),
              child: const Text(
                'Skip',
                style: TextStyle(decoration: TextDecoration.underline),
              ),
            ),
            onViewPlans:
                () => Navigator.pushNamed(
                  context,
                  AppRoutes.obProPurchase,
                  arguments: true,
                ),
          ),
        ),
      ),
    );
  }
}
