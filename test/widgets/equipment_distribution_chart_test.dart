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
    bool isVisible = true,
    bool isDataReady = true,
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
              child: EquipmentDistributionChart(
                categoryCounts: categoryCounts,
                isVisible: isVisible,
                isDataReady: isDataReady,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Finder segment(EquipmentCategory category) =>
      find.byKey(ValueKey('equipment-distribution-segment-${category.name}'));

  double segmentWidth(WidgetTester tester, EquipmentCategory category) =>
      tester.getSize(segment(category)).width;

  testWidgets('fills segments sequentially after the delay', (tester) async {
    await tester.pumpWidget(
      buildChart({
        EquipmentCategory.weights: 4,
        EquipmentCategory.racks: 3,
        EquipmentCategory.machines: 1,
        EquipmentCategory.specialty: 0,
      }),
    );
    expect(find.text('8 Items'), findsOneWidget);
    expect(segment(EquipmentCategory.weights), findsNothing);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 180));
    expect(segment(EquipmentCategory.weights), findsNothing);
    await tester.pump(const Duration(milliseconds: 240));
    expect(segmentWidth(tester, EquipmentCategory.weights), greaterThan(0));
    expect(segment(EquipmentCategory.racks), findsNothing);
    expect(segment(EquipmentCategory.machines), findsNothing);
    await tester.pump(const Duration(milliseconds: 200));
    expect(segment(EquipmentCategory.racks), findsOneWidget);
    expect(segment(EquipmentCategory.machines), findsNothing);
    expect(
      segmentWidth(tester, EquipmentCategory.weights),
      lessThanOrEqualTo(196 * 0.5),
    );
    await tester.pump(const Duration(milliseconds: 40));
    expect(
      segmentWidth(tester, EquipmentCategory.weights),
      closeTo(196 * 0.5, 0.01),
    );
    expect(
      segmentWidth(tester, EquipmentCategory.racks),
      lessThan(196 * 0.375),
    );
    await tester.pump(const Duration(milliseconds: 140));
    expect(segment(EquipmentCategory.machines), findsOneWidget);
    expect(
      segmentWidth(tester, EquipmentCategory.racks),
      closeTo(196 * 0.375, 0.01),
    );
    await tester.pump(const Duration(milliseconds: 140));
    expect(
      segmentWidth(tester, EquipmentCategory.weights),
      closeTo(196 * 0.5, 0.01),
    );
    expect(
      segmentWidth(tester, EquipmentCategory.racks),
      closeTo(196 * 0.375, 0.01),
    );
    expect(
      segmentWidth(tester, EquipmentCategory.machines),
      closeTo(196 * 0.125, 0.01),
    );
    expect(segment(EquipmentCategory.specialty), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('waits for visibility and data, and pauses when hidden', (
    tester,
  ) async {
    const counts = {EquipmentCategory.weights: 3, EquipmentCategory.racks: 1};
    await tester.pumpWidget(
      buildChart(counts, isVisible: false, isDataReady: false),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpWidget(buildChart(counts, isDataReady: false));
    await tester.pump(const Duration(seconds: 2));
    expect(segment(EquipmentCategory.weights), findsNothing);

    await tester.pumpWidget(buildChart(counts));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final beforePause = segmentWidth(tester, EquipmentCategory.weights);
    await tester.pumpWidget(buildChart(counts, isVisible: false));
    await tester.pump(const Duration(seconds: 2));
    expect(segmentWidth(tester, EquipmentCategory.weights), beforePause);
    await tester.pumpWidget(buildChart(counts));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      segmentWidth(tester, EquipmentCategory.weights),
      greaterThan(beforePause),
    );
    await tester.pumpAndSettle();
    final completed = segmentWidth(tester, EquipmentCategory.weights);
    await tester.pumpWidget(buildChart(counts, isVisible: false));
    await tester.pumpWidget(buildChart(counts));
    expect(segmentWidth(tester, EquipmentCategory.weights), completed);
  });

  testWidgets('rebuilding unchanged data does not restart the entrance', (
    tester,
  ) async {
    const counts = {EquipmentCategory.weights: 3, EquipmentCategory.racks: 1};
    await tester.pumpWidget(buildChart(counts));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final before = segmentWidth(tester, EquipmentCategory.weights);
    await tester.pumpWidget(buildChart(Map.of(counts)));
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      segmentWidth(tester, EquipmentCategory.weights),
      greaterThan(before),
    );
    await tester.pumpAndSettle();
    await tester.pumpWidget(buildChart(Map.of(counts)));
    expect(
      segmentWidth(tester, EquipmentCategory.weights),
      closeTo(148.5, 0.01),
    );
  });

  testWidgets('an update during entrance starts at the displayed width', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildChart({
        EquipmentCategory.weights: 4,
        EquipmentCategory.racks: 3,
        EquipmentCategory.machines: 1,
      }),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final before = segmentWidth(tester, EquipmentCategory.weights);
    await tester.pumpWidget(buildChart({EquipmentCategory.weights: 1}));
    expect(
      segmentWidth(tester, EquipmentCategory.weights),
      closeTo(before, 0.01),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(
      segmentWidth(tester, EquipmentCategory.weights),
      greaterThan(before),
    );
    await tester.pumpAndSettle();
    expect(segmentWidth(tester, EquipmentCategory.weights), closeTo(200, 0.01));
  });

  testWidgets(
    'interpolates normalized proportions and retargets from the frame',
    (tester) async {
      await tester.pumpWidget(
        buildChart({EquipmentCategory.weights: 3, EquipmentCategory.racks: 1}),
      );
      await tester.pumpAndSettle();
      await tester.pumpWidget(
        buildChart({EquipmentCategory.weights: 1, EquipmentCategory.racks: 9}),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      final weights = segmentWidth(tester, EquipmentCategory.weights);
      final racks = segmentWidth(tester, EquipmentCategory.racks);
      expect(
        weights,
        closeTo(
          198 * (0.75 + (0.1 - 0.75) * Curves.easeOutCubic.transform(0.5)),
          0.01,
        ),
      );
      expect(weights + racks + 2, closeTo(200, 0.01));

      await tester.pumpWidget(
        buildChart({EquipmentCategory.weights: 8, EquipmentCategory.racks: 2}),
      );
      expect(
        segmentWidth(tester, EquipmentCategory.weights),
        closeTo(weights, 0.01),
      );
      expect(
        segmentWidth(tester, EquipmentCategory.racks),
        closeTo(racks, 0.01),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(
        segmentWidth(tester, EquipmentCategory.weights),
        greaterThan(weights),
      );
      expect(
        segmentWidth(tester, EquipmentCategory.weights) +
            segmentWidth(tester, EquipmentCategory.racks) +
            2,
        closeTo(200, 0.01),
      );
      await tester.pumpAndSettle();
      expect(
        segmentWidth(tester, EquipmentCategory.weights),
        closeTo(198 * 0.8, 0.01),
      );
    },
  );

  testWidgets('reduced motion immediately completes entrance and updates', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildChart({
        EquipmentCategory.weights: 3,
        EquipmentCategory.racks: 1,
      }, disableAnimations: true),
    );
    expect(
      segmentWidth(tester, EquipmentCategory.weights),
      closeTo(148.5, 0.01),
    );
    await tester.pumpWidget(
      buildChart({EquipmentCategory.racks: 1}, disableAnimations: true),
    );
    expect(segment(EquipmentCategory.weights), findsNothing);
    expect(segmentWidth(tester, EquipmentCategory.racks), closeTo(200, 0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets('enabling reduced motion finishes an active animation', (
    tester,
  ) async {
    const counts = {EquipmentCategory.weights: 3, EquipmentCategory.racks: 1};
    await tester.pumpWidget(buildChart(counts));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(segment(EquipmentCategory.racks), findsNothing);
    await tester.pumpWidget(buildChart(counts, disableAnimations: true));
    expect(
      segmentWidth(tester, EquipmentCategory.weights),
      closeTo(148.5, 0.01),
    );
    expect(segmentWidth(tester, EquipmentCategory.racks), closeTo(49.5, 0.01));
  });

  testWidgets('later changes to and from empty do not replay the entrance', (
    tester,
  ) async {
    await tester.pumpWidget(buildChart({EquipmentCategory.weights: 1}));
    await tester.pumpAndSettle();
    await tester.pumpWidget(buildChart({}));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(
      segmentWidth(tester, EquipmentCategory.weights),
      inExclusiveRange(0, 200),
    );
    await tester.pumpAndSettle();
    expect(segment(EquipmentCategory.weights), findsNothing);
    await tester.pumpWidget(buildChart({EquipmentCategory.racks: 1}));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(segmentWidth(tester, EquipmentCategory.racks), greaterThan(0));
    await tester.pumpAndSettle();
    expect(segmentWidth(tester, EquipmentCategory.racks), closeTo(200, 0.01));
  });

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
