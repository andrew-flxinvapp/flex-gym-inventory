import 'dart:async';

import 'package:flex_gym_inventory/routes/routes.dart';
import 'package:flex_gym_inventory/src/screens/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(
  Future<String> Function() resolve, {
  Duration checkTimeout = const Duration(seconds: 8),
}) {
  final routes = <String, WidgetBuilder>{
    AppRoutes.dashboard: (_) => const Scaffold(body: Text('Dashboard')),
    AppRoutes.authLanding: (_) => const Scaffold(body: Text('Auth')),
    AppRoutes.optNotifications: (_) => const Scaffold(body: Text('Onboarding')),
    AppRoutes.startupRouter: (_) => const Scaffold(body: Text('Router')),
  };
  return MaterialApp(
    home: SplashScreen(
      key: UniqueKey(),
      resolveRoute: resolve,
      checkTimeout: checkTimeout,
      routes: routes,
    ),
  );
}

void main() {
  testWidgets('routes to dashboard, onboarding and auth landing', (t) async {
    for (final entry
        in {
          AppRoutes.dashboard: 'Dashboard',
          AppRoutes.optNotifications: 'Onboarding',
          AppRoutes.authLanding: 'Auth',
        }.entries) {
      await t.pumpWidget(const SizedBox());
      await t.pumpWidget(_app(() async => entry.key));
      await t.pump(const Duration(milliseconds: 1500));
      await t.pump();
      expect(find.text(entry.value), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
    }
  });

  testWidgets('fast startup keeps splash for at least 1.5s', (t) async {
    await t.pumpWidget(_app(() async => AppRoutes.dashboard));
    await t.pump(const Duration(milliseconds: 1400));
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await t.pump(const Duration(milliseconds: 100));
    await t.pump();
    expect(find.text('Dashboard'), findsOneWidget);
  });

  testWidgets('slow startup keeps splash until checks complete', (t) async {
    final c = Completer<String>();
    await t.pumpWidget(_app(() => c.future));
    await t.pump(const Duration(seconds: 3));
    expect(find.byType(SplashScreen), findsOneWidget);
    c.complete(AppRoutes.dashboard);
    await t.pump();
    await t.pump();
    expect(find.text('Dashboard'), findsOneWidget);
  });

  testWidgets('failure falls back to startup router', (t) async {
    await t.pumpWidget(_app(() async => throw Exception('boom')));
    await t.pump(const Duration(milliseconds: 1500));
    await t.pump();
    expect(find.text('Router'), findsOneWidget);
  });

  testWidgets('timeout falls back to startup router', (t) async {
    await t.pumpWidget(
      _app(
        () => Completer<String>().future,
        checkTimeout: const Duration(seconds: 2),
      ),
    );
    await t.pump(const Duration(seconds: 2));
    await t.pump();
    expect(find.text('Router'), findsOneWidget);
  });

  testWidgets('no navigation after disposal', (t) async {
    final c = Completer<String>();
    await t.pumpWidget(_app(() => c.future));
    await t.pumpWidget(const MaterialApp(home: Text('Other')));
    c.complete(AppRoutes.dashboard);
    await t.pump(const Duration(seconds: 2));
    expect(find.text('Other'), findsOneWidget);
    expect(find.text('Dashboard'), findsNothing);
  });
}
