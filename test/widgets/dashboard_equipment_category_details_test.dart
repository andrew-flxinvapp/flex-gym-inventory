import 'package:flex_gym_inventory/enum/app_enums.dart';
import 'package:flex_gym_inventory/src/screens/dashboard.dart';
import 'package:flex_gym_inventory/src/widgets/dashboard_equipment_breakdown.dart';
import 'package:flex_gym_inventory/src/widgets/equipment_category_details.dart';
import 'package:flex_gym_inventory/theme/app_theme.dart';
import 'package:flex_gym_inventory/view_models/dashboard_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'shows only populated categories sorted by count and enum order',
    (tester) async {
      final viewModel = _TestDashboardViewModel(
        const DashboardState(
          categoryCounts: {
            EquipmentCategory.weights: 4,
            EquipmentCategory.specialty: 0,
            EquipmentCategory.racks: 4,
            EquipmentCategory.machines: 8,
          },
          gyms: [],
        ),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [dashboardProvider.overrideWith((ref) => viewModel)],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const DashboardScreen(),
          ),
        ),
      );

      expect(find.byType(EquipmentCategoryDetails), findsNWidgets(3));
      expect(find.byType(DashboardEquipmentBreakdown), findsOneWidget);
      expect(find.text('Equipment Breakdown'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('equipment-category-machines')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('equipment-category-specialty')),
        findsNothing,
      );
      final machines = tester.getTopLeft(
        find.byKey(const ValueKey('equipment-category-machines')),
      );
      final weights = tester.getTopLeft(
        find.byKey(const ValueKey('equipment-category-weights')),
      );
      final racks = tester.getTopLeft(
        find.byKey(const ValueKey('equipment-category-racks')),
      );
      expect(machines.dx, lessThan(weights.dx));
      expect(machines.dy, closeTo(weights.dy, 0.1));
      expect(weights.dy, lessThan(racks.dy));

      final headerTitle = tester.getTopLeft(find.text('By Category'));
      final itemCount = tester.getTopLeft(find.text('16 Items'));
      expect(headerTitle.dy, lessThan(itemCount.dy));
    },
  );
}

class _TestDashboardViewModel extends DashboardViewModel {
  _TestDashboardViewModel(DashboardState initialState)
    : super(currentUserIdReader: () => null) {
    state = initialState;
  }
}
