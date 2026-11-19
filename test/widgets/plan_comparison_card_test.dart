import 'package:flex_gym_inventory/src/widgets/cards/plan_comparison_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('plan comparison displays the existing plan information', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: PlanComparisonCard())),
    );

    expect(find.text('FEATURES'), findsOneWidget);
    expect(find.text('FREE'), findsOneWidget);
    expect(find.text('PRO'), findsOneWidget);
    expect(find.text('Number of gyms'), findsOneWidget);
    expect(find.text('Number of equipment Items'), findsOneWidget);
    expect(find.text('Number of wishlist items'), findsOneWidget);
    expect(find.text('Priority support'), findsOneWidget);
    expect(find.text('Early access to new features'), findsOneWidget);

    expect(find.text('1'), findsOneWidget);
    expect(find.text('20'), findsNWidgets(2));
    expect(find.text('Unlimited'), findsNWidgets(3));
    expect(find.text('-'), findsNWidgets(2));
    expect(find.byType(Image), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}
