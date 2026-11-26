import 'package:flex_gym_inventory/src/widgets/cards/item_overview_card.dart';
import 'package:flex_gym_inventory/theme/app_icons.dart';
import 'package:flex_gym_inventory/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows category placeholder and a 3:2 image area', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    const name = 'Long-name item that wraps naturally across multiple lines';
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: ItemOverviewCard(
            name: name,
            placeholderIconAsset: AppIcons.weights,
          ),
        ),
      ),
    );

    final imageArea = tester.getSize(find.byType(AspectRatio));
    expect(imageArea.width / imageArea.height, closeTo(3 / 2, 0.001));
    final placeholder = find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName == AppIcons.weights,
    );
    expect(placeholder, findsOneWidget);
    expect(tester.getSize(placeholder), const Size(48, 48));
    final itemName = tester.widget<Text>(find.text(name));
    expect(itemName.textAlign, TextAlign.left);
    expect(
      tester.getSize(find.text(name)).height,
      greaterThan(itemName.style!.fontSize!),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows supplied image instead of the category placeholder', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: ItemOverviewCard(
            name: 'Bench',
            placeholderIconAsset: AppIcons.benches,
            image: ColoredBox(color: Colors.red),
          ),
        ),
      ),
    );

    expect(
      find.byWidgetPredicate(
        (widget) => widget is ColoredBox && widget.color == Colors.red,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName == AppIcons.benches,
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}
