import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_icons.dart';
import '../widgets/buttons/primary_button.dart';
import 'package:flex_gym_inventory/routes/routes.dart';

class UpgradeAccountScreen extends StatefulWidget {
  const UpgradeAccountScreen({super.key});

  @override
  State<UpgradeAccountScreen> createState() => _UpgradeAccountScreenState();
}

class _UpgradeAccountScreenState extends State<UpgradeAccountScreen> {
  int _selectedPlan = 0; // 0 = Monthly, 1 = Yearly
  bool _freeTrial = false;

  void _onPlanChanged(int value) {
    setState(() {
      _selectedPlan = value;
      if (_selectedPlan == 1) {
        _freeTrial = false;
      } else {
        _freeTrial = false; // Monthly plan: switch enabled but off
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool showNoPayment = _selectedPlan == 0 && _freeTrial;

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                  maxWidth: 430, // Responsive max width for large screens
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Upgrade to PRO',
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: AppTheme.lightTextPrimary,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed(AppRoutes.settings);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.lightTextPrimary,
                              padding: EdgeInsets.zero,
                              minimumSize: Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                                decoration: TextDecoration.underline,
                                color: AppTheme.lightTextPrimary,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            child: Text(
                              'Back',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                decoration: TextDecoration.underline,
                                color: AppTheme.lightTextPrimary,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Text(
                        "Unlock the full power of Flex Gym Inventory with these features:",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.lightTextPrimary,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      const SizedBox(height: 32),
                      _ProFeatureRow(
                        icon: AppIcons.gyms,
                        text: 'Unlimited Gyms',
                      ),
                      const SizedBox(height: 20),
                      _ProFeatureRow(
                        icon: AppIcons.unlimited,
                        text: 'Unlimited Equipment',
                      ),
                      const SizedBox(height: 20),
                      _ProFeatureRow(
                        icon: AppIcons.support,
                        text: 'Priority Support',
                      ),
                      const SizedBox(height: 20),
                      _ProFeatureRow(
                        icon: AppIcons.sparkle,
                        text: 'Early access to new features & updates',
                      ),
                      const SizedBox(height: 32),
                      // Upgrade Option Selector
                      Center(
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxWidth: 370),
                          height: 73,
                          decoration: BoxDecoration(
                            color: AppTheme.lightCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.lightTextPrimary,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                height: 20,
                                decoration: BoxDecoration(
                                  color: AppTheme.lightTextPrimary,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(14),
                                    topRight: Radius.circular(14),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Save 25%',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppTheme.lightCard,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16.0, right: 4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Yearly Plan',
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: AppTheme.lightTextPrimary,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Roboto',
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '\$44.99 per year',
                                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                              color: AppTheme.lightTextPrimary,
                                              fontFamily: 'Roboto',
                                            ),
                                          ),
                                        ],
                                      ),
                                      Theme(
                                        data: Theme.of(context).copyWith(
                                          unselectedWidgetColor: AppTheme.lightTextPrimary,
                                        ),
                                        child: Radio<int>(
                                          value: 1,
                                          groupValue: _selectedPlan,
                                          activeColor: AppTheme.lightTextPrimary,
                                          onChanged: (int? value) {
                                            if (value != null) _onPlanChanged(value);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxWidth: 370),
                          height: 57,
                          decoration: BoxDecoration(
                            color: AppTheme.lightCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.lightTextPrimary,
                              width: 1.5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0, right: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Monthly Plan',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppTheme.lightTextPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$4.99 per month',
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: AppTheme.lightTextPrimary,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                  ],
                                ),
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    unselectedWidgetColor: AppTheme.lightTextPrimary,
                                  ),
                                  child: Radio<int>(
                                    value: 0,
                                    groupValue: _selectedPlan,
                                    activeColor: AppTheme.lightTextPrimary,
                                    onChanged: (int? value) {
                                      if (value != null) _onPlanChanged(value);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxWidth: 370),
                          height: 47,
                          decoration: BoxDecoration(
                            color: AppTheme.lightCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.lightTextPrimary,
                              width: 1.5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '7 - Day Free Trial',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.lightTextPrimary,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                                CupertinoSwitch(
                                  value: _freeTrial,
                                  onChanged: _selectedPlan == 1
                                      ? null
                                      : (bool value) {
                                          setState(() {
                                            _freeTrial = value;
                                          });
                                        },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: PrimaryButton(
                            label: 'Start Your Trial',
                            onPressed: () {
                              // TODO: Add upgrade logic here
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Opacity(
                          opacity: showNoPayment ? 1.0 : 0.0,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                AppIcons.check,
                                height: 20,
                                width: 20,
                                color: AppTheme.successColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'No payment now',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.lightTextPrimary,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              // TODO: Open Terms of Use
                            },
                            child: Text(
                              'Terms of Use',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppTheme.lightTextPrimary,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: TextButton(
                              onPressed: () {
                                // TODO: Restore purchases
                              },
                              child: Text(
                                'Restore',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppTheme.lightTextPrimary,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // TODO: Open Privacy Policy
                            },
                            child: Text(
                              'Privacy Policy',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppTheme.lightTextPrimary,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProFeatureRow extends StatelessWidget {
  final String icon;
  final String text;

  const _ProFeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          icon,
          height: 24,
          width: 24,
          color: AppTheme.lightTextPrimary,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.lightTextPrimary,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ],
    );
  }
}
