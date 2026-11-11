import 'package:flex_gym_inventory/enum/app_enums.dart';
import 'package:flex_gym_inventory/src/widgets/cards/base_card.dart';
import 'package:flex_gym_inventory/src/widgets/dashboard_equipment_breakdown.dart';
import 'package:flex_gym_inventory/src/widgets/equipment_category_details.dart';
import 'package:flex_gym_inventory/src/widgets/equipment_distribution_chart.dart';
import 'package:flex_gym_inventory/theme/app_theme.dart';
import 'package:flex_gym_inventory/view_models/dashboard_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final northGym = _gym('north', 'North Gym', 2);
  final southGym = _gym('south', 'South Gym', 3);
  final emptyGym = _gym('empty', 'Empty Gym', 0);

  testWidgets('shows all-gym totals, chart, and sorted category details', (
    tester,
  ) async {
    final viewModel = _TestDashboardViewModel(
      _populatedState(gyms: [northGym, southGym, emptyGym]),
    );
    await tester.pumpWidget(_buildApp(viewModel));
    await tester.pumpAndSettle();

    expect(find.byType(BaseCard), findsOneWidget);
    expect(find.byType(EquipmentDistributionChart), findsOneWidget);
    expect(find.text('7 Items'), findsOneWidget);
    expect(find.byType(EquipmentCategoryDetails), findsNWidgets(2));
    expect(find.text('Weights'), findsOneWidget);
    expect(find.text('Racks'), findsOneWidget);
    expect(find.text('57%'), findsOneWidget);
    expect(find.text('43%'), findsOneWidget);
  });

  testWidgets('filters selected gym statistics and returns to All Gyms', (
    tester,
  ) async {
    final viewModel = _TestDashboardViewModel(
      _populatedState(gyms: [northGym, southGym, emptyGym]),
    );
    await tester.pumpWidget(_buildApp(viewModel));
    await tester.pumpAndSettle();

    await _chooseGym(tester, 'North Gym');
    await tester.pumpAndSettle();
    expect(find.text('2 Items'), findsOneWidget);
    expect(find.byType(EquipmentCategoryDetails), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);

    await _chooseGym(tester, 'South Gym');
    await tester.pumpAndSettle();
    expect(find.text('3 Items'), findsOneWidget);
    expect(find.text('Racks'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);

    await _chooseGym(tester, 'All Gyms', selectLast: true);
    await tester.pumpAndSettle();
    expect(find.text('7 Items'), findsOneWidget);
    expect(find.byType(EquipmentCategoryDetails), findsNWidgets(2));
  });

  testWidgets('shows the empty state for an empty selected gym', (
    tester,
  ) async {
    final viewModel = _TestDashboardViewModel(
      _populatedState(gyms: [northGym, emptyGym]),
    );
    await tester.pumpWidget(_buildApp(viewModel));
    await tester.pumpAndSettle();

    await _chooseGym(tester, 'Empty Gym');
    await tester.pumpAndSettle();

    expect(find.text('0 Items'), findsOneWidget);
    expect(find.text('No equipment yet'), findsOneWidget);
    expect(
      find.text('Add equipment to see your category breakdown.'),
      findsOneWidget,
    );
    expect(find.byType(EquipmentCategoryDetails), findsNothing);
  });

  testWidgets('resets to All Gyms when the selected gym disappears', (
    tester,
  ) async {
    final viewModel = _TestDashboardViewModel(
      _populatedState(gyms: [northGym, southGym]),
    );
    await tester.pumpWidget(_buildApp(viewModel));
    await tester.pumpAndSettle();

    await _chooseGym(tester, 'North Gym');
    await tester.pumpAndSettle();
    expect(find.text('2 Items'), findsOneWidget);

    viewModel.update(
      _populatedState(
        gyms: [southGym],
        categoryCounts: const {EquipmentCategory.racks: 3},
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('All Gyms'), findsOneWidget);
    expect(find.text('3 Items'), findsOneWidget);
  });

  testWidgets('updates chart and details when dashboard data changes', (
    tester,
  ) async {
    final viewModel = _TestDashboardViewModel(
      _populatedState(gyms: [northGym, southGym]),
    );
    await tester.pumpWidget(_buildApp(viewModel));
    await tester.pumpAndSettle();
    expect(find.text('7 Items'), findsOneWidget);

    viewModel.update(
      _populatedState(
        gyms: [northGym, southGym],
        categoryCounts: const {
          EquipmentCategory.weights: 5,
          EquipmentCategory.machines: 1,
        },
        northCounts: const {EquipmentCategory.weights: 4},
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('6 Items'), findsOneWidget);
    expect(find.text('Weights'), findsOneWidget);
    expect(find.text('Machines'), findsOneWidget);
    expect(find.byType(EquipmentCategoryDetails), findsNWidgets(2));
  });

  testWidgets('uses a single-column fallback at scaled text sizes', (
    tester,
  ) async {
    final viewModel = _TestDashboardViewModel(
      _populatedState(gyms: [northGym, southGym]),
    );
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: _buildApp(viewModel, width: 280),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}

Widget _buildApp(_TestDashboardViewModel viewModel, {double width = 390}) {
  return ProviderScope(
    overrides: [dashboardProvider.overrideWith((ref) => viewModel)],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            child: const DashboardEquipmentBreakdown(),
          ),
        ),
      ),
    ),
  );
}

Future<void> _chooseGym(
  WidgetTester tester,
  String label, {
  bool selectLast = false,
}) async {
  await tester.tap(
    find.byKey(const ValueKey('equipment-breakdown-gym-selector')),
  );
  await tester.pumpAndSettle();
  final option = find.text(label);
  await tester.tap(selectLast ? option.last : option.last);
  await tester.pumpAndSettle();
}

DashboardState _populatedState({
  required List<DashboardGym> gyms,
  Map<EquipmentCategory, int> categoryCounts = const {
    EquipmentCategory.weights: 4,
    EquipmentCategory.racks: 3,
  },
  Map<EquipmentCategory, int> northCounts = const {
    EquipmentCategory.weights: 2,
  },
}) {
  return DashboardState(
    gyms: gyms,
    categoryCounts: categoryCounts,
    gymCategoryCounts: {
      'north': northCounts,
      'south': const {EquipmentCategory.racks: 3},
      'empty': const {},
    },
  );
}

DashboardGym _gym(String id, String name, int count) => DashboardGym(
  gymId: id,
  gymName: name,
  equipmentCount: count,
  lastUpdated: DateTime(2026),
);

class _TestDashboardViewModel extends DashboardViewModel {
  _TestDashboardViewModel(DashboardState initialState)
    : super(currentUserIdReader: () => null) {
    state = initialState;
  }

  void update(DashboardState next) => state = next;
}
