import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../widgets/layouts/gradient_background.dart';
import '../../routes/routes.dart';
import '../widgets/displays/social_proof_display.dart';
import '../widgets/cards/plan_comparison_card.dart';
import '../widgets/displays/purchase_info_item.dart';
import '../widgets/placeholders/vertical_divider.dart';
import '../widgets/cards/subscription_plan_card.dart';
import '../providers/price_provider.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/displays/footer_links.dart';

class NewOnboardingUpgrade extends StatelessWidget {
  const NewOnboardingUpgrade({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GradientBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Upgrade to PRO',
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(color: AppTheme.darkTextPrimary),
                      ),
                      TextButton(
                        onPressed:
                            () => Navigator.pushNamed(
                              context,
                              AppRoutes.complete,
                            ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.darkTextPrimary,
                          textStyle: Theme.of(context).textTheme.bodySmall,
                        ),
                        child: const Text('Skip'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SocialProofDisplay(),
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
                        const Center(child: PlanComparisonCard()),
                        const SizedBox(height: 8),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Flexible(
                                fit: FlexFit.loose,
                                child: PurchaseInfoItem(
                                  label: '7-day free trial',
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              SizedBox(
                                width: 40,
                                height: 32,
                                child: Center(
                                  child: CustomVerticalDivider(height: 16),
                                ),
                              ),
                              Flexible(
                                fit: FlexFit.loose,
                                child: PurchaseInfoItem(
                                  label: 'No commitment',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(
                                width: 40,
                                height: 32,
                                child: Center(
                                  child: CustomVerticalDivider(height: 16),
                                ),
                              ),
                              Flexible(
                                fit: FlexFit.loose,
                                child: PurchaseInfoItem(
                                  label: 'Cancel anytime',
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SubscriptionPlanCard(
                                title: 'Monthly',
                                price: PriceProvider.monthlyPrice,
                                badge: '7-day free trial',
                                variant: SubscriptionPlanCardVariant.monthly,
                                selected: true,
                                onTap: () {},
                              ),
                              const SizedBox(width: 16),
                              SubscriptionPlanCard(
                                title: 'Yearly',
                                price: PriceProvider.yearlyPrice,
                                badge: 'Save 25%',
                                variant: SubscriptionPlanCardVariant.yearly,
                                selected: false,
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: PrimaryButton(
                            label: 'Redeem Your Free Week',
                            onPressed: () {},
                            variant: PrimaryButtonVariant.dark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: FooterLinks(
                            onRestore: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Restore Purchases pressed'),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
