import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../view_models/dashboard_view_model.dart';

class EquipmentBreakdownHeader extends StatelessWidget {
  final List<DashboardGym> gyms;
  final String? selectedGymId;
  final ValueChanged<String?> onSelectionChanged;

  const EquipmentBreakdownHeader({
    super.key,
    required this.gyms,
    required this.selectedGymId,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    var selectedLabel = 'All Gyms';
    for (final gym in gyms) {
      if (gym.gymId == selectedGymId) {
        selectedLabel = gym.gymName;
        break;
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final selectorWidth =
            constraints.maxWidth < 110 ? constraints.maxWidth : 102.0;
        final titleToSelectorGap = constraints.maxWidth < 110 ? 0.0 : 8.0;
        final horizontalPadding = selectorWidth < 72 ? 4.0 : 10.0;
        final selectorGap = selectorWidth < 80 ? 4.0 : 16.0;

        return Row(
          children: [
            Expanded(
              child: Text(
                'By Category',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTextPrimary,
                ),
              ),
            ),
            SizedBox(width: titleToSelectorGap),
            SizedBox(
              width: selectorWidth,
              height: 24,
              child: PopupMenuButton<_GymSelection>(
                key: const ValueKey('equipment-breakdown-gym-selector'),
                enabled: gyms.isNotEmpty,
                tooltip: 'Select gym',
                padding: EdgeInsets.zero,
                onSelected: (selection) => onSelectionChanged(selection.gymId),
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: _GymSelection(gymId: null),
                        child: Text('All Gyms'),
                      ),
                      for (final gym in gyms)
                        PopupMenuItem(
                          value: _GymSelection(gymId: gym.gymId),
                          child: Text(
                            gym.gymName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                child: Container(
                  key: const ValueKey('equipment-breakdown-gym-selector-box'),
                  width: selectorWidth,
                  height: 22,
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    2,
                    horizontalPadding,
                    2,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.lightTextPrimary,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppTheme.lightTextPrimary),
                        ),
                      ),
                      SizedBox(width: selectorGap),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: AppTheme.lightTextPrimary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GymSelection {
  final String? gymId;

  const _GymSelection({required this.gymId});
}
