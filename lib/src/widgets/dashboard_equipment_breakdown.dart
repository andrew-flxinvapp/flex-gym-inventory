import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../enum/app_enums.dart';
import '../../theme/app_theme.dart';
import '../../view_models/dashboard_view_model.dart';
import 'cards/base_card.dart';
import 'equipment_breakdown_header.dart';
import 'equipment_category_details.dart';
import 'equipment_distribution_chart.dart';

class DashboardEquipmentBreakdown extends ConsumerStatefulWidget {
  const DashboardEquipmentBreakdown({super.key});

  @override
  ConsumerState<DashboardEquipmentBreakdown> createState() =>
      _DashboardEquipmentBreakdownState();
}

class _DashboardEquipmentBreakdownState
    extends ConsumerState<DashboardEquipmentBreakdown> {
  String? _selectedGymId;

  @override
  Widget build(BuildContext context) {
    ref.listen<DashboardState>(dashboardProvider, (previous, next) {
      final selectedGymId = _selectedGymId;
      if (selectedGymId != null &&
          !next.gyms.any((gym) => gym.gymId == selectedGymId)) {
        setState(() => _selectedGymId = null);
      }
    });

    final dashboard = ref.watch(dashboardProvider);
    final gyms = dashboard.gyms;
    final selectedGymId =
        gyms.any((gym) => gym.gymId == _selectedGymId) ? _selectedGymId : null;
    final categoryCounts =
        selectedGymId == null
            ? dashboard.categoryCounts
            : dashboard.gymCategoryCounts[selectedGymId] ??
                {for (final category in EquipmentCategory.values) category: 0};
    final populatedCategoryCounts =
        categoryCounts.entries.where((entry) => entry.value > 0).toList()
          ..sort((a, b) {
            final countOrder = b.value.compareTo(a.value);
            return countOrder != 0
                ? countOrder
                : a.key.index.compareTo(b.key.index);
          });
    final orderedCategoryCounts = Map<EquipmentCategory, int>.fromEntries(
      populatedCategoryCounts,
    );
    final total = populatedCategoryCounts.fold<int>(
      0,
      (sum, entry) => sum + entry.value,
    );

    return BaseCard(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EquipmentBreakdownHeader(
            gyms: gyms,
            selectedGymId: selectedGymId,
            onSelectionChanged: (gymId) {
              if (gymId == null || gyms.any((gym) => gym.gymId == gymId)) {
                setState(() => _selectedGymId = gymId);
              }
            },
          ),
          const SizedBox(height: 12),
          EquipmentDistributionChart(categoryCounts: orderedCategoryCounts),
          const SizedBox(height: 22),
          if (populatedCategoryCounts.isEmpty)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'No equipment yet',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppTheme.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add equipment to see your category breakdown.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final useTwoColumns =
                    constraints.maxWidth >= 282 &&
                    MediaQuery.textScalerOf(context).scale(14) <= 18;
                final columns = useTwoColumns ? 2 : 1;
                final itemWidth =
                    (constraints.maxWidth - (columns - 1) * 22) / columns;
                return Wrap(
                  spacing: 22,
                  runSpacing: 22,
                  children: [
                    for (final entry in populatedCategoryCounts)
                      SizedBox(
                        width: itemWidth,
                        child: EquipmentCategoryDetails(
                          key: ValueKey('equipment-category-${entry.key.name}'),
                          category: entry.key,
                          count: entry.value,
                          percentage: entry.value / total * 100,
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
