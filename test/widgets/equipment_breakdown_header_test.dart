import 'package:flex_gym_inventory/src/widgets/equipment_breakdown_header.dart';
import 'package:flex_gym_inventory/theme/app_theme.dart';
import 'package:flex_gym_inventory/view_models/dashboard_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final gyms = [_gym('gym-1', 'North Gym'), _gym('gym-2', 'South Gym')];

  Widget buildHeader({
    List<DashboardGym> gyms = const [],
    String? selectedGymId,
    ValueChanged<String?>? onSelectionChanged,
    double width = 320,
  }) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            child: EquipmentBreakdownHeader(
              gyms: gyms,
              selectedGymId: selectedGymId,
              onSelectionChanged: onSelectionChanged ?? (_) {},
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('defaults to All Gyms and displays the themed header', (
    tester,
  ) async {
    await tester.pumpWidget(buildHeader());

    expect(find.text('By Category'), findsOneWidget);
    expect(find.text('All Gyms'), findsOneWidget);
    final title = tester.widget<Text>(find.text('By Category'));
    expect(
      title.style?.fontSize,
      AppTheme.lightTheme.textTheme.titleMedium?.fontSize,
    );
    expect(
      tester.getSize(
        find.byKey(const ValueKey('equipment-breakdown-gym-selector-box')),
      ),
      const Size(102, 24),
    );
  });

  testWidgets('selecting a gym and All Gyms reports nullable IDs', (
    tester,
  ) async {
    String? selection = 'unchanged';
    await tester.pumpWidget(
      buildHeader(gyms: gyms, onSelectionChanged: (id) => selection = id),
    );

    await tester.tap(
      find.byKey(const ValueKey('equipment-breakdown-gym-selector')),
    );
    await tester.pumpAndSettle();
    expect(find.text('All Gyms'), findsNWidgets(2));
    expect(find.text('North Gym'), findsOneWidget);
    expect(find.text('South Gym'), findsOneWidget);

    await tester.tap(find.text('North Gym'));
    await tester.pumpAndSettle();
    expect(selection, 'gym-1');

    await tester.tap(
      find.byKey(const ValueKey('equipment-breakdown-gym-selector')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('All Gyms').last);
    await tester.pumpAndSettle();
    expect(selection, isNull);
  });

  testWidgets('allows choosing the only available gym', (tester) async {
    String? selection;
    await tester.pumpWidget(
      buildHeader(
        gyms: [gyms.first],
        onSelectionChanged: (id) => selection = id,
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('equipment-breakdown-gym-selector')),
    );
    await tester.pumpAndSettle();
    expect(find.text('All Gyms'), findsNWidgets(2));
    expect(find.text('North Gym'), findsOneWidget);
    expect(find.text('South Gym'), findsNothing);
    await tester.tap(find.text('North Gym'));
    await tester.pumpAndSettle();
    expect(selection, 'gym-1');
  });

  testWidgets('disables the selector when no gyms are available', (
    tester,
  ) async {
    await tester.pumpWidget(buildHeader());

    final selector = tester.widget<PopupMenuButton<dynamic>>(
      find.byKey(const ValueKey('equipment-breakdown-gym-selector')),
    );
    expect(selector.enabled, isFalse);
    await tester.tap(
      find.byKey(const ValueKey('equipment-breakdown-gym-selector')),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
    expect(find.text('All Gyms'), findsOneWidget);
  });

  testWidgets('falls back to All Gyms for a deleted selection', (tester) async {
    await tester.pumpWidget(
      buildHeader(gyms: gyms, selectedGymId: 'deleted-gym'),
    );

    expect(find.text('All Gyms'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ellipsizes long names without overflowing a narrow header', (
    tester,
  ) async {
    final gym = _gym(
      'gym-long-name',
      'An Extremely Long Gym Name That Should Not Overflow',
    );
    await tester.pumpWidget(
      buildHeader(gyms: [gym], selectedGymId: gym.gymId, width: 180),
    );

    final selectedName = tester.widget<Text>(
      find.text('An Extremely Long Gym Name That Should Not Overflow'),
    );
    expect(selectedName.maxLines, 1);
    expect(selectedName.overflow, TextOverflow.ellipsis);
    expect(tester.takeException(), isNull);
  });
}

DashboardGym _gym(String id, String name) => DashboardGym(
  gymId: id,
  gymName: name,
  equipmentCount: 0,
  lastUpdated: DateTime(2026),
);
