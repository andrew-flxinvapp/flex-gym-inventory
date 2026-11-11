import 'package:flutter/material.dart';

import '../../enum/app_enums.dart';
import '../../theme/app_theme.dart';

class EquipmentCategoryDetails extends StatelessWidget {
  final EquipmentCategory category;
  final int count;
  final double percentage;

  const EquipmentCategoryDetails({
    super.key,
    required this.category,
    required this.count,
    required this.percentage,
  }) : assert(count > 0),
       assert(percentage >= 0 && percentage <= 100);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final itemLabel = '$count ${count == 1 ? 'item' : 'items'}';
    final roundedPercentage = percentage.round();

    return Semantics(
      container: true,
      label: '${category.label}, $itemLabel, $roundedPercentage percent',
      child: ExcludeSemantics(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 34),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                key: const ValueKey('equipment-category-details-indicator'),
                width: 6,
                height: 32,
                decoration: BoxDecoration(
                  color: category.color,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final countText = Text(
                          itemLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.lightTextPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                        final percentageText = Text(
                          '$roundedPercentage%',
                          textAlign: TextAlign.right,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTextPrimary,
                          ),
                        );

                        if (constraints.maxWidth < 100 ||
                            MediaQuery.textScalerOf(context).scale(14) > 18) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              countText,
                              Align(
                                alignment: Alignment.bottomRight,
                                child: percentageText,
                              ),
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(child: countText),
                            const SizedBox(width: 4),
                            percentageText,
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
