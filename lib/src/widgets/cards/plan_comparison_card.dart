import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_icons.dart';

class PlanComparisonCard extends StatelessWidget {
  const PlanComparisonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final headerStyleFeatures = textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.bold,
      color: AppTheme.darkTextPrimary,
    );

    final headerStyleFree = textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.bold,
      color: AppTheme.darkTextPrimary,
    );

    final headerStylePro = textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.bold,
      color: AppTheme.updateColor,
    );

    final featureLabels = [
      'Number of gyms',
      'Number of equipment Items',
      'Number of wishlist items',
      'Priority support',
      'Early access to new features',
    ];

    final freeValues = ['1', '20', '20', '-', '-'];
    final proValues = ['Unlimited', 'Unlimited', 'Unlimited', '-', '-'];

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 370,
        decoration: BoxDecoration(
          color: AppTheme.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(width: 1, color: AppTheme.darkDividers),
        ),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(0.99),
            2: FlexColumnWidth(0.99),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            // header
            TableRow(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 1, color: AppTheme.darkDividers),
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text('FEATURES', style: headerStyleFeatures),
                ),
                Container(
                  decoration: const BoxDecoration(
                    border: Border(right: BorderSide(width: 1, color: AppTheme.darkDividers)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text('FREE', style: headerStyleFree, textAlign: TextAlign.center),
                  ),
                ),
                Container(
                  color: AppTheme.lightTextPrimary.withValues(alpha: 0.4),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('PRO', style: headerStylePro, textAlign: TextAlign.center),
                    ),
                  ),
                ),
              ],
            ),

            // data rows
            for (var i = 0; i < featureLabels.length; i++)
              TableRow(
                decoration: i < featureLabels.length - 1
                    ? const BoxDecoration(
                        border: Border(bottom: BorderSide(width: 1, color: AppTheme.darkDividers)),
                      )
                    : null,
                children: [
                  // Feature label
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    child: Text(featureLabels[i], style: textTheme.labelSmall?.copyWith(color: AppTheme.darkTextPrimary)),
                  ),

                  // FREE column (with left and right strokes)
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(width: 1, color: AppTheme.darkDividers),
                        right: BorderSide(width: 1, color: AppTheme.darkDividers),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                      child: Center(
                        child: Text(freeValues[i], style: textTheme.labelSmall?.copyWith(color: AppTheme.darkTextPrimary)),
                      ),
                    ),
                  ),

                  // PRO column (text for first 3 rows, icon for last 2)
                  Container(
                    color: AppTheme.lightTextPrimary.withValues(alpha: 0.4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                      child: Center(
                        child: i < 3
                            ? FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(proValues[i], style: textTheme.labelSmall?.copyWith(color: AppTheme.updateColor), maxLines: 1, softWrap: false),
                              )
                            : Image.asset(
                                AppIcons.check,
                                width: 18,
                                height: 18,
                                color: AppTheme.updateColor,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
