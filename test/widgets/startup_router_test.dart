import 'dart:async';

import 'package:flex_gym_inventory/routes/routes.dart';
import 'package:flex_gym_inventory/src/data/repositories/onboarding_repository.dart';
import 'package:flex_gym_inventory/src/screens/startup_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockOnboardingRepository extends Mock implements OnboardingRepository {}

class FakeSession extends Fake implements Session {}

Widget _routerApp(
  OnboardingRepository repository, {
  Duration startupTimeout = const Duration(seconds: 8),
}) {
  final routes = Map<String, WidgetBuilder>.from(appRoutes);
  routes.remove(AppRoutes.splash);
  routes[AppRoutes.dashboard] =
      (_) => const Scaffold(body: Center(child: Text('Dashboard')));
  routes[AppRoutes.optNotifications] =
      (_) => const Scaffold(body: Center(child: Text('Onboarding')));

  return MaterialApp(
    routes: routes,
    home: StartupRouterScreen(
      onboardingRepository: repository,
      testSession: FakeSession(),
      startupTimeout: startupTimeout,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StartupRouterScreen', () {
    late _MockOnboardingRepository mockRepo;

    setUp(() {
      mockRepo = _MockOnboardingRepository();
    });

    testWidgets('routes unauthenticated users to auth landing without lookup', (
      tester,
    ) async {
      await Supabase.initialize(
        url: 'https://example.supabase.co',
        publishableKey: 'test-anon-key',
        authOptions: const FlutterAuthClientOptions(
          autoRefreshToken: false,
          persistSession: false,
          detectSessionInUri: false,
        ),
      );
      expect(Supabase.instance.client.auth.currentSession, isNull);

      final routes = Map<String, WidgetBuilder>.from(appRoutes);
      routes.remove(AppRoutes.splash);
      routes[AppRoutes.authLanding] =
          (_) => const Scaffold(body: Center(child: Text('Auth landing')));

      await tester.pumpWidget(
        MaterialApp(
          routes: routes,
          home: StartupRouterScreen(onboardingRepository: mockRepo),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Auth landing'), findsOneWidget);
      verifyNever(() => mockRepo.fetchOnboardingCompleteFromProfile());

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('navigates to onboarding when onboarding is incomplete', (
      tester,
    ) async {
      when(
        () => mockRepo.fetchOnboardingCompleteFromProfile(),
      ).thenAnswer((_) async => false);

      await tester.pumpWidget(_routerApp(mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('Onboarding'), findsOneWidget);
      verify(() => mockRepo.fetchOnboardingCompleteFromProfile()).called(1);
    });

    testWidgets('navigates to dashboard when onboarding is complete', (
      tester,
    ) async {
      when(
        () => mockRepo.fetchOnboardingCompleteFromProfile(),
      ).thenAnswer((_) async => true);

      await tester.pumpWidget(_routerApp(mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
      verify(() => mockRepo.fetchOnboardingCompleteFromProfile()).called(1);
    });

    testWidgets('shows an error and retry continues startup resolution', (
      tester,
    ) async {
      var attempts = 0;
      final retryResult = Completer<bool>();
      when(() => mockRepo.fetchOnboardingCompleteFromProfile()).thenAnswer((
        _,
      ) async {
        attempts++;
        if (attempts == 1) throw Exception('Temporary profile lookup failure');
        return retryResult.future;
      });

      await tester.pumpWidget(_routerApp(mockRepo));
      await tester.pumpAndSettle();

      expect(find.text("We couldn't check your profile."), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Onboarding'), findsNothing);

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(attempts, 2);
      expect(find.text('Retry'), findsNothing);
      retryResult.complete(true);
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
      expect(attempts, 2);
    });

    testWidgets('timeout shows recovery and retry ignores a late result', (
      tester,
    ) async {
      final timedOutResult = Completer<bool>();
      var attempts = 0;
      when(() => mockRepo.fetchOnboardingCompleteFromProfile()).thenAnswer((_) {
        attempts++;
        return attempts == 1 ? timedOutResult.future : Future<bool>.value(true);
      });

      await tester.pumpWidget(_routerApp(mockRepo));
      await tester.pump(const Duration(seconds: 8));
      await tester.pump();

      expect(find.text("We couldn't check your profile."), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(attempts, 1);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
      expect(attempts, 2);

      timedOutResult.complete(false);
      await tester.pumpAndSettle();
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Onboarding'), findsNothing);
    });

    testWidgets(
      'each retry is bounded and Retry is hidden during an active attempt',
      (tester) async {
        // Future.timeout does not cancel the underlying request; keep these
        // futures pending to verify late results cannot affect newer attempts.
        final timedOutResults = [Completer<bool>(), Completer<bool>()];
        var attempts = 0;
        when(() => mockRepo.fetchOnboardingCompleteFromProfile()).thenAnswer((
          _,
        ) {
          attempts++;
          if (attempts <= timedOutResults.length) {
            return timedOutResults[attempts - 1].future;
          }
          return Future<bool>.value(true);
        });

        await tester.pumpWidget(_routerApp(mockRepo));
        await tester.pump(const Duration(seconds: 8));
        await tester.pump();
        expect(find.text('Retry'), findsOneWidget);
        expect(attempts, 1);

        await tester.tap(find.text('Retry'));
        await tester.pump();
        expect(attempts, 2);
        expect(find.text('Retry'), findsNothing);

        await tester.pump(const Duration(seconds: 8));
        await tester.pump();
        expect(find.text('Retry'), findsOneWidget);
        expect(attempts, 2);

        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();
        expect(find.text('Dashboard'), findsOneWidget);
        expect(attempts, 3);

        timedOutResults[0].complete(false);
        timedOutResults[1].complete(false);
        await tester.pumpAndSettle();
        expect(find.text('Dashboard'), findsOneWidget);
      },
    );

    testWidgets('does not navigate after disposal during profile lookup', (
      tester,
    ) async {
      final result = Completer<bool>();
      when(
        () => mockRepo.fetchOnboardingCompleteFromProfile(),
      ).thenAnswer((_) => result.future);

      await tester.pumpWidget(_routerApp(mockRepo));
      await tester.pump();
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Other screen'))),
      );

      result.complete(true);
      await tester.pumpAndSettle();

      expect(find.text('Other screen'), findsOneWidget);
      expect(find.text('Dashboard'), findsNothing);
      expect(find.text('Onboarding'), findsNothing);
    });
  });
}
