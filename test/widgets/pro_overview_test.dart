import 'package:flex_gym_inventory/routes/routes.dart';
import 'package:flex_gym_inventory/src/screens/ob_upgrade_info.dart';
import 'package:flex_gym_inventory/src/screens/upgrade_info.dart';
import 'package:flex_gym_inventory/src/widgets/layouts/pro_overview_layout.dart';
import 'package:flex_gym_inventory/theme/app_icons.dart';
import 'package:flex_gym_inventory/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('content spacing adapts and the headline wraps', (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final theme = AppTheme.lightTheme;
    final headlineTheme = theme.copyWith(
      textTheme: theme.textTheme.copyWith(
        titleSmall: theme.textTheme.titleSmall?.copyWith(fontSize: 14),
      ),
    );
    final headline = find.text('Get more out of Flex Gym Inventory');
    final icon = find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName == AppIcons.upgrade,
    );
    final header = find.text('Pro Overview');
    double? previousGap;

    for (final height in [600.0, 844.0]) {
      tester.view.physicalSize = Size(390, height);
      await tester.pumpWidget(
        MaterialApp(
          theme: headlineTheme,
          home: Scaffold(
            body: ProOverviewLayout(
              headerAction: const SizedBox(width: 48, height: 48),
              onViewPlans: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final paragraph = tester.renderObject<RenderParagraph>(headline);
      final lines = paragraph.getBoxesForSelection(
        const TextSelection(baseOffset: 0, extentOffset: 34),
      );
      expect(lines, hasLength(2));
      final gap = tester.getTopLeft(icon).dy - tester.getBottomLeft(header).dy;
      expect(gap, greaterThan(24));
      if (previousGap != null) expect(gap, greaterThan(previousGap));
      previousGap = gap;
      expect(tester.takeException(), isNull);
    }
  });

  for (final onboarding in [true, false]) {
    for (final viewPlans in [true, false]) {
      testWidgets(
        '${onboarding ? 'Onboarding' : 'In-app'} overview ${viewPlans ? 'views plans' : 'dismisses'}',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = const Size(320, 568);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);
          RouteSettings? destination;

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
              home: Builder(
                builder:
                    (context) => Scaffold(
                      body: TextButton(
                        onPressed:
                            () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder:
                                    (_) =>
                                        onboarding
                                            ? const OnboardingUpgradeInfo()
                                            : const UpgradeInfo(),
                              ),
                            ),
                        child: const Text('Open overview'),
                      ),
                    ),
              ),
              onGenerateRoute: (settings) {
                destination = settings;
                return MaterialPageRoute<void>(
                  settings: settings,
                  builder:
                      (_) => const Scaffold(body: Text('Route destination')),
                );
              },
            ),
          );
          await tester.tap(find.text('Open overview'));
          await tester.pumpAndSettle();

          expect(find.text('Skip'), onboarding ? findsOneWidget : findsNothing);
          expect(
            find.byTooltip('Back'),
            onboarding ? findsNothing : findsOneWidget,
          );
          expect(
            find.byWidgetPredicate(
              (widget) =>
                  widget is Image &&
                  widget.image is AssetImage &&
                  (widget.image as AssetImage).assetName == AppIcons.upgrade,
            ),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);

          if (viewPlans) {
            await tester.ensureVisible(find.text('View Plans'));
            await tester.pumpAndSettle();
            expect(find.text('Number of gyms'), findsOneWidget);
            expect(find.text('Unlimited'), findsNWidgets(3));
            expect(tester.takeException(), isNull);
            await tester.tap(find.text('View Plans'));
            await tester.pumpAndSettle();
            expect(
              destination?.name,
              onboarding ? AppRoutes.obProPurchase : AppRoutes.proPurchase,
            );
            expect(destination?.arguments, onboarding ? isTrue : isNull);
          } else if (onboarding) {
            await tester.tap(find.text('Skip'));
            await tester.pumpAndSettle();
            expect(destination?.name, AppRoutes.complete);
          } else {
            await tester.tap(find.byTooltip('Back'));
            await tester.pumpAndSettle();
            expect(find.text('Open overview'), findsOneWidget);
            expect(destination, isNull);
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
