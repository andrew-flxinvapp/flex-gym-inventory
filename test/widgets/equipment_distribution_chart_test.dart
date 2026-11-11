import 'package:flex_gym_inventory/enum/app_enums.dart';
import 'package:flex_gym_inventory/src/widgets/equipment_distribution_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildChart(
    Map<EquipmentCategory, int> categoryCounts, {
    double width = 200,
    double textScale = 1,
    bool disableAnimations = false,
  }) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          textScaler: TextScaler.linear(textScale),
          disableAnimations: disableAnimations,
        ),
        child: Scaffold(
          body: Center(
            child: SizedBox(
              width: width,
              child: EquipmentDistributionChart(categoryCounts: categoryCounts),
            ),
          ),
        ),
      ),
    );
  }

  Finder segment(EquipmentCategory category) =>
      find.byKey(ValueKey('equipment-distribution-segment-${category.name}'));

  testWidgets('renders the total and proportional populated categories', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildChart({
        EquipmentCategory.weights: 3,
        EquipmentCategory.racks: 1,
        EquipmentCategory.machines: 0,
      }),
    );
    await tester.pumpAndSettle();

    expect(find.text('4 Items'), findsOneWidget);
    expect(segment(EquipmentCategory.weights), findsOneWidget);
    expect(segment(EquipmentCategory.racks), findsOneWidget);
    expect(segment(EquipmentCategory.machines), findsNothing);
    expect(
      tester.getSize(segment(EquipmentCategory.weights)).width,
      closeTo((200 - 2) * 0.75, 0.1),
    );
    expect(
      tester.getSize(segment(EquipmentCategory.racks)).width,
      closeTo((200 - 2) * 0.25, 0.1),
    );
    expect(
      tester
          .widget<ColoredBox>(
            find.descendant(
              of: segment(EquipmentCategory.weights),
              matching: find.byType(ColoredBox),
            ),
          )
          .color,
      EquipmentCategory.weights.color,
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey('equipment-distribution-bar')))
          .height,
      24,
    );
  });

  testWidgets('renders an empty neutral bar and announces zero items', (
    tester,
  ) async {
    await tester.pumpWidget(buildChart({}));
    await tester.pumpAndSettle();

    expect(find.text('0 Items'), findsOneWidget);
    expect(segment(EquipmentCategory.weights), findsNothing);
    expect(find.bySemanticsLabel('0 items'), findsOneWidget);
  });

  testWidgets('updates counts and proportions without replacing the widget', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildChart({EquipmentCategory.weights: 3, EquipmentCategory.racks: 1}),
    );
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      buildChart({EquipmentCategory.weights: 1, EquipmentCategory.machines: 3}),
    );
    await tester.pumpAndSettle();

    expect(find.text('4 Items'), findsOneWidget);
    expect(segment(EquipmentCategory.racks), findsNothing);
    expect(segment(EquipmentCategory.machines), findsOneWidget);
    expect(
      tester.getSize(segment(EquipmentCategory.weights)).width,
      closeTo((200 - 2) * 0.25, 0.1),
    );
    expect(
      tester.getSize(segment(EquipmentCategory.machines)).width,
      closeTo((200 - 2) * 0.75, 0.1),
    );
  });

  testWidgets('supports every category, large counts, and narrow scaled text', (
    tester,
  ) async {
    final counts = {
      for (final category in EquipmentCategory.values) category: 1000000000,
    };
    await tester.pumpWidget(
      buildChart(counts, width: 120, textScale: 2, disableAnimations: true),
    );

    expect(find.text('10000000000 Items'), findsOneWidget);
    for (final category in EquipmentCategory.values) {
      expect(segment(category), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('animates transitions to and from an empty dataset', (
    tester,
  ) async {
    await tester.pumpWidget(buildChart({}));
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      buildChart({EquipmentCategory.weights: 1}, disableAnimations: true),
    );
    await tester.pumpAndSettle();
    expect(segment(EquipmentCategory.weights), findsOneWidget);
    expect(find.text('1 Items'), findsOneWidget);

    await tester.pumpWidget(buildChart({}, disableAnimations: true));
    await tester.pumpAndSettle();
    expect(segment(EquipmentCategory.weights), findsNothing);
    expect(find.text('0 Items'), findsOneWidget);
  });
}
