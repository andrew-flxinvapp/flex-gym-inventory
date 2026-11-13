import 'package:flex_gym_inventory/routes/routes.dart';
import 'package:flex_gym_inventory/src/screens/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app({Duration minDuration = const Duration(milliseconds: 1500)}) {
  final routes = <String, WidgetBuilder>{
    AppRoutes.startupRouter: (_) => const Scaffold(body: Text('Router')),
  };
  return MaterialApp(
    home: SplashScreen(minDuration: minDuration, routes: routes),
  );
}

void main() {
  testWidgets('keeps splash for the minimum duration then opens router', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pump(const Duration(milliseconds: 1499));
    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('Router'), findsOneWidget);
    expect(find.byType(SplashScreen), findsNothing);
  });

  testWidgets('does not navigate after splash is disposed', (tester) async {
    await tester.pumpWidget(_app(minDuration: const Duration(seconds: 2)));
    await tester.pumpWidget(const MaterialApp(home: Text('Other')));
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Other'), findsOneWidget);
    expect(find.text('Router'), findsNothing);
  });
}
