import 'package:flutter/material.dart';

import '../../routes/routes.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_icons.dart';
import '../widgets/layouts/app_screen.dart';
import '../widgets/layouts/pro_overview_layout.dart';

class UpgradeInfo extends StatelessWidget {
  const UpgradeInfo({super.key});

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
            headerAction: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Image.asset(
                AppIcons.close,
                width: 20,
                height: 20,
                color: AppTheme.darkTextPrimary,
              ),
              tooltip: 'Back',
            ),
            onViewPlans:
                () => Navigator.pushNamed(
                  context,
                  AppRoutes.proPurchase,
                ),
          ),
        ),
      ),
    );
  }
}
