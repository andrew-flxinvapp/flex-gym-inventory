import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/purchase_flow_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../routes/routes.dart';
import '../../theme/app_theme.dart';
import '../providers/price_provider.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/buttons/secondary_button.dart';
import '../widgets/cards/monthly_plan_card.dart';
import '../widgets/cards/yearly_plan_card.dart';
import '../widgets/displays/purchase_info_item.dart';
import '../widgets/layouts/app_screen.dart';

class ProPurchase extends ConsumerStatefulWidget {
  final bool isOnboarding;

  const ProPurchase({super.key, this.isOnboarding = false});

  @override
  ConsumerState<ProPurchase> createState() => _ProPurchaseState();
}

class _ProPurchaseState extends ConsumerState<ProPurchase> {
  SubscriptionPlan _selectedPlan = SubscriptionPlan.monthly;

  Future<void> _handlePurchase() async {
    final outcome = await ref
        .read(purchaseFlowProvider.notifier)
        .purchase(_selectedPlan);
    if (!mounted || outcome == TransactionOutcome.cancelled) return;
    _showOutcome(outcome, restore: false);
  }

  Future<void> _handleRestore() async {
    final outcome = await ref.read(purchaseFlowProvider.notifier).restore();
    if (!mounted) return;
    _showOutcome(outcome, restore: true);
  }

  void _showOutcome(TransactionOutcome outcome, {required bool restore}) {
    final message = switch (outcome) {
      TransactionOutcome.confirmed => 'PRO subscription is active.',
      TransactionOutcome.pending =>
        'The transaction or subscription verification is pending. Please check again later.',
      TransactionOutcome.noEntitlement =>
        'No active PRO subscription was found.',
      TransactionOutcome.identityChanged =>
        'Your account changed. The transaction may have completed; check the original account.',
      TransactionOutcome.failed =>
        restore
            ? 'Could not restore purchases. Please try again.'
            : 'Could not confirm the purchase. Check your subscription before trying again.',
      TransactionOutcome.cancelled => '',
    };
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleNotNow() {
    final navigator = Navigator.of(context);
    if (widget.isOnboarding) {
      navigator.pushNamed(AppRoutes.complete);
      return;
    }

    navigator.popUntil(ModalRoute.withName(AppRoutes.upgradeInfo));
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(purchaseFlowProvider);
    ref.watch(subscriptionProvider);
    final canRestore =
        ref.read(revenueCatServiceProvider).isCurrentSupabaseUserSynchronized &&
        !flow.isBusy;
    final monthly = flow.monthly?.storeProduct;
    final annual = flow.annual?.storeProduct;
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
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                          maxWidth: 430,
                        ),
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16.0,
                                16.0,
                                16.0,
                                0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                    description:
                                        flow.status == OfferingStatus.loading
                                            ? 'Loading price...'
                                            : PriceProvider.monthlyPrice(
                                              monthly,
                                            ),
                                    isSelected:
                                        _selectedPlan ==
                                        SubscriptionPlan.monthly,
                                    onTap: () {
                                      setState(
                                        () =>
                                            _selectedPlan =
                                                SubscriptionPlan.monthly,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  YearlyPlanCard(
                                    description:
                                        flow.status == OfferingStatus.loading
                                            ? 'Loading price...'
                                            : PriceProvider.yearlyPrice(annual),
                                    savings: PriceProvider.annualSavings(
                                      monthly,
                                      annual,
                                    ),
                                    isSelected:
                                        _selectedPlan ==
                                        SubscriptionPlan.annual,
                                    onTap: () {
                                      setState(
                                        () =>
                                            _selectedPlan =
                                                SubscriptionPlan.annual,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  PrimaryButton(
                                    label:
                                        flow.isBusy
                                            ? 'Please wait...'
                                            : 'Subscribe',
                                    onPressed:
                                        !flow.isBusy &&
                                                flow.status ==
                                                    OfferingStatus.ready &&
                                                flow.packageFor(
                                                      _selectedPlan,
                                                    ) !=
                                                    null
                                            ? _handlePurchase
                                            : null,
                                    variant: PrimaryButtonVariant.dark,
                                  ),
                                  if (flow.status ==
                                      OfferingStatus.unavailable) ...[
                                    Text(
                                      flow.message ??
                                          'Subscriptions are unavailable.',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: AppTheme.darkTextPrimary,
                                      ),
                                    ),
                                    if (canRestore)
                                      TextButton(
                                        onPressed:
                                            () =>
                                                ref
                                                    .read(
                                                      purchaseFlowProvider
                                                          .notifier,
                                                    )
                                                    .retry(),
                                        child: const Text('Try again'),
                                      ),
                                  ],
                                  const SizedBox(height: 16),
                                  SecondaryButton(
                                    label: 'Not Now',
                                    onPressed: _handleNotNow,
                                    foregroundColor: AppTheme.darkTextPrimary,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildFooterLinks(context, canRestore),
                                ],
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
            label: 'App Store billing',
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

  Widget _buildFooterLinks(BuildContext context, bool canRestore) {
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
            onTap: canRestore ? _handleRestore : null,
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
