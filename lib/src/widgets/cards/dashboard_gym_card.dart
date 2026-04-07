import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_icons.dart';
import 'base_card.dart';

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

    return BaseCard(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                AppIcons.round,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gymName,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: AppTheme.lightTextPrimary,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            equipmentCount.toString(),
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: AppTheme.lightTextPrimary,
                                ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Equipment Items',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: AppTheme.lightTextPrimary,
                                  fontWeight: FontWeight.normal,
                                ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 24,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Image.asset(
                                  AppIcons.forward,
                                  color: AppTheme.dividers,
                                  width: 24,
                                  height: 24,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: AppTheme.dividers,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Updated $daysAgo Days Ago',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.lightTextPrimary,
                            ),
                      ),
                  ],
                ),
              ),
              
            ],
          ),
          // Removed equipment/update row to simplify card
        ],
      ),
    );
  }
}
