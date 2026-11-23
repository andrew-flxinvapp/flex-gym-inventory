import 'package:flex_gym_inventory/routes/routes.dart';
import 'package:flex_gym_inventory/src/screens/welcome.dart';
import 'package:flex_gym_inventory/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('welcome content scrolls at large text sizes and continues', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        builder:
            (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
        home: const WelcomeScreen(),
        routes: {
          AppRoutes.socialProof:
              (context) =>
                  const Scaffold(body: Text('Social proof destination')),
        },
      ),
    );
    await tester.pumpAndSettle();

    final illustration = find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName ==
              'lib/assets/images/new_welcome.png',
    );
    final heading = find.text('Meet Flex Rackley!');
    expect(illustration, findsOneWidget);
    expect(heading, findsOneWidget);
    expect(
      tester.getTopLeft(illustration).dy,
      lessThan(tester.getTopLeft(heading).dy),
    );

    final finalParagraph = find.text(
      "You handle the heavy lifting. He's got the rest covered.",
    );
    await tester.ensureVisible(finalParagraph);
    await tester.pumpAndSettle();
    expect(finalParagraph, findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Social proof destination'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
