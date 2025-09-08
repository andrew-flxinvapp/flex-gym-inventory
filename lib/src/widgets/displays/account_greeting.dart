import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import 'package:flex_gym_inventory/theme/app_icons.dart';

class AccountGreeting extends StatelessWidget {
  const AccountGreeting({super.key});

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning,';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon,';
    } else {
      return 'Good Evening,';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.lightSecondary,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              AppIcons.round,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              getGreeting(),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppTheme.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Flex',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.lightPrimary,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
