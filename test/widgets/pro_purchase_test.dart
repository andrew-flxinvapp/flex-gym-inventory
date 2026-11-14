import 'package:flex_gym_inventory/src/screens/pro_purchase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('positions the header 16 pixels below the safe area', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(400, 900),
            padding: EdgeInsets.only(top: 30),
          ),
          child: ProPurchase(),
        ),
      ),
    );

    final logo = find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName ==
              'lib/assets/images/logo_pro.png',
    );
    final heading = find.text('More room for your gym.');
    expect(tester.getTopLeft(logo).dy, 46);
    expect(tester.getTopLeft(heading).dy, tester.getBottomLeft(logo).dy + 24);
  });
}
