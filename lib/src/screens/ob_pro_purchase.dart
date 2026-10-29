import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../routes/routes.dart';
import '../../theme/app_theme.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/buttons/secondary_button.dart';
import '../widgets/cards/monthly_plan_card.dart';
import '../widgets/cards/yearly_plan_card.dart';
import '../widgets/displays/purchase_info_item.dart';
import '../widgets/layouts/app_screen.dart';

enum _SubscriptionPlan { monthly, yearly }

class ObProPurchase extends StatefulWidget {
  const ObProPurchase({super.key});

  @override
  State<ObProPurchase> createState() => _ProPurchaseState();
}

class _ProPurchaseState extends State<ObProPurchase> {
  _SubscriptionPlan _selectedPlan = _SubscriptionPlan.monthly;

  void _handlePurchase() {
    switch (_selectedPlan) {
      case _SubscriptionPlan.monthly:
        // TODO: Start the selected monthly subscription with RevenueCat.
        break;
      case _SubscriptionPlan.yearly:
        // TODO: Start the selected yearly subscription with RevenueCat.
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: AppScreen(
        safeArea: false,
        backgroundColor: AppTheme.darkBackground,
        lightSystemUi: true,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'lib/assets/images/auth_land_bg.png',
              fit: BoxFit.cover,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.9, -0.62),
                  radius: 1.6,
                  focal: Alignment(0.9, -0.7),
                  focalRadius: 0.001,
                  colors: [
                    Color(0x991F4F66),
                    Color(0xB3023246),
                    Color(0xD9010D1B),
                    Color(0xF2000000),
                  ],
                  stops: [0.0, 0.3, 0.8, 1.0],
                  transform: GradientRotation(0.25),
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 430),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 24.0),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16.0,
                                  0,
                                  16.0,
                                  0,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Center(
                                      child: Image.asset(
                                        'lib/assets/images/logo_pro.png',
                                        height: 60,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      'More room for your gym.',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.displaySmall?.copyWith(
                                        color: AppTheme.darkTextPrimary,
                                      ),
                                    ),
                                    const Spacer(),
                                    _buildReassurance(context),
                                    const SizedBox(height: 16),
                                    MonthlyPlanCard(
                                      isSelected:
                                          _selectedPlan ==
                                          _SubscriptionPlan.monthly,
                                      onTap: () {
                                        setState(
                                          () =>
                                              _selectedPlan =
                                                  _SubscriptionPlan.monthly,
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    YearlyPlanCard(
                                      isSelected:
                                          _selectedPlan ==
                                          _SubscriptionPlan.yearly,
                                      onTap: () {
                                        setState(
                                          () =>
                                              _selectedPlan =
                                                  _SubscriptionPlan.yearly,
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    PrimaryButton(
                                      label: 'Start 7-day Free Trial',
                                      onPressed: _handlePurchase,
                                      variant: PrimaryButtonVariant.dark,
                                    ),
                                    const SizedBox(height: 16),
                                    SecondaryButton(
                                      label: 'Not Now',
                                      onPressed: () {
                                        Navigator.of(
                                          context,
                                        ).pushNamed(AppRoutes.complete);
                                      },
                                      foregroundColor: AppTheme.darkTextPrimary,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildFooterLinks(context),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReassurance(BuildContext context) {
    final style = Theme.of(
      context,
    ).textTheme.labelSmall?.copyWith(color: AppTheme.darkTextPrimary);

    return Row(
      children: [
        Expanded(
          child: PurchaseInfoItem(
            label: '7-day free trial',
            style: style,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: PurchaseInfoItem(
            label: 'No commitment',
            style: style,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: PurchaseInfoItem(
            label: 'Cancel anytime',
            style: style,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildFooterLinks(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: AppTheme.darkTextPrimary,
      fontSize: 10,
    );

    return Row(
      children: [
        Expanded(
          child: PurchaseInfoItem(
            label: 'Terms of Use',
            style: style,
            textAlign: TextAlign.center,
            onTap:
                () => _openLegalLink(
                  context,
                  Uri.parse(
                    'https://flexgyminventory.app/terms-and-conditions',
                  ),
                  'Could not open Terms and Conditions',
                ),
          ),
        ),
        _buildFooterDivider(),
        Expanded(
          child: PurchaseInfoItem(
            label: 'Restore Purchases',
            style: style,
            textAlign: TextAlign.center,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Restore Purchases will be available in a future update.',
                  ),
                ),
              );
            },
          ),
        ),
        _buildFooterDivider(),
        Expanded(
          child: PurchaseInfoItem(
            label: 'Privacy Policy',
            style: style,
            textAlign: TextAlign.center,
            onTap:
                () => _openLegalLink(
                  context,
                  Uri.parse('https://flexgyminventory.app/privacy-policy'),
                  'Could not open Privacy Policy',
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterDivider() {
    return Container(width: 1, height: 16, color: AppTheme.darkDividers);
  }

  Future<void> _openLegalLink(
    BuildContext context,
    Uri uri,
    String errorMessage,
  ) async {
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  }
}
