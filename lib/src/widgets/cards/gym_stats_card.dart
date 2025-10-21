import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class GymStatsCard extends StatelessWidget {
  final int itemCount;
  final double estimatedValue;
  final DateTime lastUpdated;

  const GymStatsCard({
    super.key,
    required this.itemCount,
    required this.estimatedValue,
    required this.lastUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 370,
      height: 168,
      decoration: BoxDecoration(
        color: AppTheme.lightCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Number of Items',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.lightPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              itemCount.toString(),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppTheme.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Estimated Value Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estimated Value',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${estimatedValue.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppTheme.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
                // Last Updated Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Last Updated Date',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(lastUpdated),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppTheme.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  // Helper to format date as MM/dd/yyyy
  String _formatDate(DateTime date) {
    return "${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}";
  }
}
