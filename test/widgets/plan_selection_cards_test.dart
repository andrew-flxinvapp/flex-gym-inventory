import 'package:flex_gym_inventory/src/providers/price_provider.dart';
import 'package:flex_gym_inventory/src/widgets/cards/monthly_plan_card.dart';
import 'package:flex_gym_inventory/src/widgets/cards/yearly_plan_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'monthly and yearly cards display provider prices and parent selection',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      var monthlySelected = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    MonthlyPlanCard(
                      isSelected: monthlySelected,
                      onTap: () => setState(() => monthlySelected = true),
                    ),
                    YearlyPlanCard(
                      isSelected: !monthlySelected,
                      onTap: () => setState(() => monthlySelected = false),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      Semantics planSemantics(String plan) {
        return tester.widget<Semantics>(
          find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                (widget.properties.label?.startsWith(plan) ?? false),
          ),
        );
      }

      expect(
        find.text('${PriceProvider.monthlyPrice} with 7-day trial'),
        findsOneWidget,
      );
      expect(
        find.text('${PriceProvider.yearlyPrice} with 7-day trial'),
        findsOneWidget,
      );
      expect(find.text('Save 25%'), findsOneWidget);
      expect(planSemantics('Monthly').properties.selected, isTrue);
      expect(planSemantics('Yearly').properties.selected, isFalse);

      await tester.tap(find.text('Yearly'));
      await tester.pump();

      expect(planSemantics('Monthly').properties.selected, isFalse);
      expect(planSemantics('Yearly').properties.selected, isTrue);
      expect(tester.takeException(), isNull);
    },
  );
}
