import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../providers/price_provider.dart';
import 'base_card.dart';

class MonthlyPlanCard extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const MonthlyPlanCard({
    super.key,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final description = '${PriceProvider.monthlyPrice} with 7-day trial';

    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Monthly, $description',
      child: BaseCard(
        color: AppTheme.lightTextPrimary,
        border: Border.all(
          color: isSelected ? AppTheme.lightBackground : AppTheme.transparent,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [],
        onTap: onTap,
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.lightBackground,
                    width: 2,
                  ),
                ),
                child:
                    isSelected
                        ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppTheme.lightBackground,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                        : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.lightBackground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightBackground,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
