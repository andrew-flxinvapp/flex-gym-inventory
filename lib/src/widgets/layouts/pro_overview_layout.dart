import 'package:flutter/material.dart';

import '../../../constant/subscription_constants.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_theme.dart';
import '../cards/plan_comparison_card.dart';

class ProOverviewLayout extends StatelessWidget {
  final Widget headerAction;
  final VoidCallback onViewPlans;

  const ProOverviewLayout({
    super.key,
    required this.headerAction,
    required this.onViewPlans,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${SubscriptionConstants.proPlanName} Overview',
                  style: textTheme.displayMedium?.copyWith(
                    color: AppTheme.darkTextPrimary,
                  ),
                ),
              ),
              headerAction,
            ],
          ),
          Expanded(
            child: LayoutBuilder(
              builder:
                  (context, constraints) => SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: (constraints.maxHeight * 0.12).clamp(
                            32.0,
                            96.0,
                          ),
                        ),
                        Center(
                          child: Image.asset(
                            AppIcons.upgrade,
                            width: 128,
                            height: 128,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 370),
                            child: Text(
                              'Get more out of Flex Gym Inventory',
                              style: textTheme.titleMedium?.copyWith(
                                color: AppTheme.darkTextPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          SubscriptionConstants.proOverviewDescription,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppTheme.darkTextPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        const PlanComparisonCard(),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: onViewPlans,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.lightBackground,
                            foregroundColor: AppTheme.lightTextPrimary,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(
                                color: AppTheme.darkBackground,
                              ),
                            ),
                          ),
                          child: Text(
                            'View Plans',
                            style: textTheme.bodyLarge?.copyWith(
                              color: AppTheme.lightTextPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
