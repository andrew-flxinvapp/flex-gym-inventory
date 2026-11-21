import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import 'base_card.dart';

class YearlyPlanCard extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final String description;
  final int? savings;

  const YearlyPlanCard({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.description,
    this.savings,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Yearly, $description${savings == null ? '' : ', Save $savings%'}',
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
                  border: Border.all(color: AppTheme.lightBackground, width: 2),
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Yearly',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.lightBackground,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (savings != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.successColor.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: AppTheme.successColor),
                          ),
                          child: Text(
                            'Save $savings%',
                            style: Theme.of(
                              context,
                            ).textTheme.labelSmall?.copyWith(
                              color: AppTheme.successColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
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
