import 'package:flex_gym_inventory/enum/app_enums.dart';
import 'package:flex_gym_inventory/src/widgets/equipment_category_details.dart';
import 'package:flex_gym_inventory/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildDetails({
    required EquipmentCategory category,
    required int count,
    required double percentage,
    double width = 180,
    double textScale = 1,
  }) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: Scaffold(
          body: Center(
            child: SizedBox(
              width: width,
              child: EquipmentCategoryDetails(
                category: category,
                count: count,
                percentage: percentage,
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders singular item text and rounds the percentage', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildDetails(
        category: EquipmentCategory.weights,
        count: 1,
        percentage: 33.7,
      ),
    );

    expect(find.text('Weights'), findsOneWidget);
    expect(find.text('1 item'), findsOneWidget);
    expect(find.text('34%'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Weights, 1 item, 34 percent'),
      findsOneWidget,
    );
  });

  testWidgets('renders plural item text and the category color indicator', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildDetails(category: EquipmentCategory.racks, count: 3, percentage: 75),
    );

    expect(find.text('3 items'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    final indicator = tester.widget<Container>(
      find.byKey(const ValueKey('equipment-category-details-indicator')),
    );
    expect(
      (indicator.decoration! as BoxDecoration).color,
      EquipmentCategory.racks.color,
    );
    expect(
      tester.getSize(
        find.byKey(const ValueKey('equipment-category-details-indicator')),
      ),
      const Size(6, 28),
    );
  });

  testWidgets('uses the requested theme typography and colors', (tester) async {
    await tester.pumpWidget(
      buildDetails(
        category: EquipmentCategory.machines,
        count: 5,
        percentage: 100,
      ),
    );

    final categoryName = tester.widget<Text>(find.text('Machines'));
    final itemCount = tester.widget<Text>(find.text('5 items'));
    final percentage = tester.widget<Text>(find.text('100%'));

    expect(
      categoryName.style?.fontSize,
      AppTheme.lightTheme.textTheme.bodySmall?.fontSize,
    );
    expect(
      itemCount.style?.fontSize,
      AppTheme.lightTheme.textTheme.bodyMedium?.fontSize,
    );
    expect(itemCount.style?.fontWeight, FontWeight.bold);
    expect(
      percentage.style?.fontSize,
      AppTheme.lightTheme.textTheme.bodySmall?.fontSize,
    );
    expect(categoryName.style?.color, AppTheme.lightTextPrimary);
  });

  testWidgets('aligns the percentage with the item count at grid width', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildDetails(
        category: EquipmentCategory.weights,
        count: 6,
        percentage: 60,
        width: 154,
      ),
    );

    final itemCount = tester.getRect(find.text('6 items'));
    final percentage = tester.getRect(find.text('60%'));
    expect(itemCount.bottom, closeTo(percentage.bottom, 0.1));
  });

  testWidgets('avoids overflow at narrow widths with scaled text', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildDetails(
        category: EquipmentCategory.accessories,
        count: 123456789,
        percentage: 99.9,
        width: 100,
        textScale: 2,
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
