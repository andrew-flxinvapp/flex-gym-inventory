import 'dart:ui' as ui;

import 'package:flex_gym_inventory/src/widgets/animations/animated_completion_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

const _iconBoundaryKey = ValueKey('completion-icon-boundary');

Widget _buildIcon({bool disableAnimations = false}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: const Scaffold(
        body: Center(
          child: RepaintBoundary(
            key: _iconBoundaryKey,
            child: AnimatedCompletionIcon(),
          ),
        ),
      ),
    ),
  );
}

Future<int> _alphaAt(WidgetTester tester, int x, int y) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_iconBoundaryKey),
  );
  return await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1);
        final data =
            (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
        final alpha = data.getUint8((y * image.width + x) * 4 + 3);
        image.dispose();
        return alpha;
      }) ??
      fail('Could not read the rendered icon.');
}

void main() {
  testWidgets('draws the circle before the check and remains completed', (
    tester,
  ) async {
    await tester.pumpWidget(_buildIcon());
    expect(await _alphaAt(tester, 5, 64), 0);

    await tester.pump(const Duration(milliseconds: 300));
    expect(await _alphaAt(tester, 5, 64), greaterThan(0));
    expect(await _alphaAt(tester, 55, 82), 0);

    await tester.pump(const Duration(milliseconds: 300));
    expect(await _alphaAt(tester, 55, 82), 0);

    await tester.pump(const Duration(milliseconds: 100));
    expect(await _alphaAt(tester, 55, 82), greaterThan(0));

    await tester.pump(const Duration(milliseconds: 250));
    expect(await _alphaAt(tester, 55, 82), greaterThan(0));
    await tester.pump(const Duration(seconds: 1));
    expect(await _alphaAt(tester, 55, 82), greaterThan(0));
  });

  testWidgets('does not restart when rebuilt during the animation', (
    tester,
  ) async {
    await tester.pumpWidget(_buildIcon());
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpWidget(_buildIcon());
    await tester.pump(const Duration(milliseconds: 300));

    expect(await _alphaAt(tester, 118, 87), greaterThan(0));
    expect(await _alphaAt(tester, 55, 82), 0);

    await tester.pump(const Duration(milliseconds: 350));
    expect(await _alphaAt(tester, 55, 82), greaterThan(0));
  });

  testWidgets('reduced motion displays the completed icon immediately', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(_buildIcon(disableAnimations: true));
    expect(await _alphaAt(tester, 5, 64), greaterThan(0));
    expect(await _alphaAt(tester, 55, 82), greaterThan(0));
    expect(find.bySemanticsLabel('Completed'), findsOneWidget);
    semantics.dispose();

    await tester.pumpWidget(_buildIcon());
    await tester.pump(const Duration(milliseconds: 100));
    expect(await _alphaAt(tester, 55, 82), greaterThan(0));
  });

  testWidgets('reduced motion completes an animation already in progress', (
    tester,
  ) async {
    await tester.pumpWidget(_buildIcon());
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpWidget(_buildIcon(disableAnimations: true));
    expect(await _alphaAt(tester, 55, 82), greaterThan(0));

    await tester.pumpWidget(_buildIcon());
    await tester.pump(const Duration(milliseconds: 100));
    expect(await _alphaAt(tester, 55, 82), greaterThan(0));
  });

  testWidgets('can be disposed while the drawing animation is running', (
    tester,
  ) async {
    await tester.pumpWidget(_buildIcon());
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });
}
