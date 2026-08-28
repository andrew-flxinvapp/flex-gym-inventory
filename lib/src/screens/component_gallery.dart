import 'package:flutter/material.dart';
// import '../../theme/app_theme.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/displays/user_count.dart';
import '../widgets/displays/user_ratings.dart';
import '../widgets/displays/purchase_reassurance.dart';
import '../widgets/displays/footer_links.dart';
import '../data/dtos/social_proof_content.dart';
import '../widgets/displays/social_proof_display.dart';
import '../widgets/layouts/gradient_background.dart';
import '../widgets/cards/plan_comparison_card.dart';
import '../widgets/cards/subscription_plan_card.dart';
import '../providers/price_provider.dart';

class ComponentGallery extends StatelessWidget {
  const ComponentGallery({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: const TopAppBar(title: 'Component Gallery'),
        body: GradientBackground(
          child: SafeArea(
            child: Center(
              child: SizedBox(
                width: 370,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      UserCount(data: socialProofContent),
                      const SizedBox(height: 12),
                      const UserRatings(),
                      const SizedBox(height: 12),
                      SocialProofDisplay(data: socialProofContent),
                      const SizedBox(height: 12),
                      const PurchaseReassurance(),
                      const SizedBox(height: 12),
                      const PlanComparisonCard(),
                      const SizedBox(height: 12),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SubscriptionPlanCard(
                              title: 'Monthly',
                              // TODO: replace with RevenueCat via PriceProvider
                              price: PriceProvider.monthlyPrice,
                              badge: '7-day free trial',
                              variant: SubscriptionPlanCardVariant.monthly,
                              selected: true,
                              onTap: () {},
                            ),
                            const SizedBox(width: 12),
                            SubscriptionPlanCard(
                              title: 'Yearly',
                              // TODO: replace with RevenueCat via PriceProvider
                              price: PriceProvider.yearlyPrice,
                              badge: 'Save 25%',
                              variant: SubscriptionPlanCardVariant.yearly,
                              selected: false,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      FooterLinks(
                        onRestore: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Restore Purchases pressed')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
