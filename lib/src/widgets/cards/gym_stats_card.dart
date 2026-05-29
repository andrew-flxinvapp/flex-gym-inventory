import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import 'base_card.dart';

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
    return BaseCard(
      width: 370,
      color: AppTheme.lightCard,
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Equipment',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: AppTheme.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            itemCount.toString(),
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: AppTheme.lightTextPrimary,
            ),
          ),
        ],
      ),
      body: IntrinsicHeight(
        child: Row(
          children: [
            // Estimated Value Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estimated Value',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.lightTextPrimary,
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
            ),

            const VerticalDivider(
              width: 16,
              thickness: 1,
              indent: 4,
              endIndent: 4,
              color: AppTheme.dividers,
            ),

            // Last Updated Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Last Updated',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.lightTextPrimary,
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
            ),
          ],
        ),
      ),
    );
  }

  // Helper to format date as MM/dd/yyyy
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24 && date.day == now.day) return '${diff.inHours}h ago';
    if (date.year == now.year && date.month == now.month && date.day == now.day) return 'Today';
    // Fallback to MM/dd/yyyy
    return "${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}";
  }
}
