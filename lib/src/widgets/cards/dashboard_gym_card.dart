import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_icons.dart';

class DashboardGymCard extends StatelessWidget {
  final String gymName;
  final int equipmentCount;
  final DateTime lastUpdated;

  const DashboardGymCard({
    super.key,
    required this.gymName,
    required this.equipmentCount,
    required this.lastUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final int daysAgo = DateTime.now().difference(lastUpdated).inDays;
    return Container(
      width: 370,
      height: 135,
      decoration: BoxDecoration(
        color: AppTheme.lightCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  AppIcons.round,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    gymName,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: AppTheme.lightTextPrimary,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  'Equipment:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTextPrimary,
                      ),
                ),
                const SizedBox(width: 8),
                Text(
                  equipmentCount.toString(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTextPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Text(
                  'Updated $daysAgo days ago',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.lightPrimary.withOpacity(0.6),
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
