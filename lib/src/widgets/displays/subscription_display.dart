import 'package:flutter/material.dart';
import '../cards/subscription_plan_card.dart';

/// SubscriptionDisplay
///
/// Displays two SubscriptionPlanCard widgets side-by-side: monthly (left)
/// and yearly (right). This widget is intentionally lightweight and simply
/// composes the two plan cards into a single row.
class SubscriptionDisplay extends StatelessWidget {
  final SubscriptionPlanCard monthlyCard;
  final SubscriptionPlanCard yearlyCard;
  final double spacing;

  const SubscriptionDisplay({
    Key? key,
    required this.monthlyCard,
    required this.yearlyCard,
    this.spacing = double.infinity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        monthlyCard,
        SizedBox(width: spacing),
        yearlyCard,
      ],
    );
  }
}
