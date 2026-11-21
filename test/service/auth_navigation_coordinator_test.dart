import 'dart:async';

import 'package:flex_gym_inventory/routes/routes.dart';
import 'package:flex_gym_inventory/service/auth_navigation_coordinator.dart';
import 'package:flex_gym_inventory/src/data/repositories/onboarding_repository.dart';
import 'package:flex_gym_inventory/src/screens/startup_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockOnboardingRepository extends Mock implements OnboardingRepository {}

final _session = Session(
  accessToken: 'test',
  tokenType: 'bearer',
  user: const User(
    id: 'user',
    appMetadata: {},
    userMetadata: {},
    aud: 'authenticated',
    createdAt: '',
  ),
);

void main() {
  late StreamController<AuthState> events;
  late GlobalKey<NavigatorState> navigatorKey;
  late GlobalKey<ScaffoldMessengerState> messengerKey;
  late AuthNavigationCoordinator coordinator;
  String? userId;
  var startupVisits = 0;

  setUp(() {
    userId = null;
    startupVisits = 0;
    events = StreamController<AuthState>.broadcast(sync: true);
    navigatorKey = GlobalKey<NavigatorState>();
    messengerKey = GlobalKey<ScaffoldMessengerState>();
    coordinator = AuthNavigationCoordinator(
      navigatorKey: navigatorKey,
      messengerKey: messengerKey,
      currentUserId: () => userId,
      authChanges: events.stream,
    );
  });

  tearDown(() async {
    await coordinator.dispose();
    await events.close();
  });

  Widget app(String initialRoute) => MaterialApp(
    navigatorKey: navigatorKey,
    scaffoldMessengerKey: messengerKey,
    navigatorObservers: [coordinator],
    initialRoute: initialRoute,
    routes: {
      AppRoutes.splash: (_) => const Scaffold(body: Text('Splash')),
      AppRoutes.verifyEmail: (_) => const Scaffold(body: Text('Verify')),
      AppRoutes.authLanding: (_) => const Scaffold(body: Text('Landing')),
      AppRoutes.startupRouter: (_) {
        startupVisits++;
        return const Scaffold(body: Text('Startup'));
      },
    },
  );

  testWidgets('resumed sign-in navigates once only after a confirmed session', (
    tester,
  ) async {
    await tester.pumpWidget(app(AppRoutes.verifyEmail));
    events.add(AuthState(AuthChangeEvent.signedIn, _session));
    await tester.pumpAndSettle();
    expect(find.text('Verify'), findsOneWidget);

    userId = 'user';
    events.add(AuthState(AuthChangeEvent.signedIn, _session));
    events.add(AuthState(AuthChangeEvent.signedIn, _session));
    await tester.pumpAndSettle();
    expect(find.text('Startup'), findsOneWidget);
    expect(startupVisits, 1);
  });

  testWidgets('cold-start sign-in leaves splash to resolve the session', (
    tester,
  ) async {
    userId = 'user';
    events.add(AuthState(AuthChangeEvent.signedIn, _session));
    await tester.pumpWidget(app(AppRoutes.splash));
    await tester.pumpAndSettle();
    expect(find.text('Splash'), findsOneWidget);
    expect(startupVisits, 0);
    navigatorKey.currentState!.pushReplacementNamed(AppRoutes.startupRouter);
    await tester.pumpAndSettle();
    expect(find.text('Startup'), findsOneWidget);
    expect(startupVisits, 1);
  });

  testWidgets('existing session on verify redirects without a new auth event', (
    tester,
  ) async {
    userId = 'user';
    await tester.pumpWidget(app(AppRoutes.verifyEmail));
    await tester.pumpAndSettle();
    expect(find.text('Startup'), findsOneWidget);
    expect(startupVisits, 1);
  });

  testWidgets(
    'auth errors are surfaced without navigating and allow recovery',
    (tester) async {
      events.addError(Exception('sensitive callback details'));
      await tester.pumpWidget(app(AppRoutes.authLanding));
      await tester.pump();
      expect(
        find.text(
          'Authentication failed. Check your connection or request a new link.',
        ),
        findsOneWidget,
      );
      expect(find.text('Landing'), findsOneWidget);
      expect(startupVisits, 0);

      userId = 'user';
      events.add(AuthState(AuthChangeEvent.signedIn, _session));
      await tester.pumpAndSettle();
      expect(find.text('Startup'), findsOneWidget);
      expect(startupVisits, 1);
    },
  );

  testWidgets('sign-out or stale sign-in cannot cause success navigation', (
    tester,
  ) async {
    await tester.pumpWidget(app(AppRoutes.authLanding));
    events.add(const AuthState(AuthChangeEvent.signedOut, null));
    events.add(AuthState(AuthChangeEvent.signedIn, _session));
    await tester.pumpAndSettle();
    expect(find.text('Landing'), findsOneWidget);
    expect(startupVisits, 0);
  });

  testWidgets('recovery authentication with a session also resumes startup', (
    tester,
  ) async {
    await tester.pumpWidget(app(AppRoutes.verifyEmail));
    userId = 'user';
    events.add(AuthState(AuthChangeEvent.passwordRecovery, _session));
    await tester.pumpAndSettle();
    expect(find.text('Startup'), findsOneWidget);
    expect(startupVisits, 1);
  });

  testWidgets(
    'sign-out cancels pending navigation and permits signing in again',
    (tester) async {
      await tester.pumpWidget(app(AppRoutes.authLanding));
      userId = 'user';
      events.add(AuthState(AuthChangeEvent.signedIn, _session));
      userId = null;
      events.add(const AuthState(AuthChangeEvent.signedOut, null));
      await tester.pumpAndSettle();
      expect(find.text('Landing'), findsOneWidget);
      expect(startupVisits, 0);

      userId = 'user';
      events.add(AuthState(AuthChangeEvent.signedIn, _session));
      await tester.pumpAndSettle();
      expect(find.text('Startup'), findsOneWidget);
      expect(startupVisits, 1);
    },
  );

  for (final complete in [true, false]) {
    testWidgets(
      'authenticated callback routes ${complete ? 'completed' : 'new'} user correctly',
      (tester) async {
        final repository = _MockOnboardingRepository();
        when(
          () => repository.fetchOnboardingCompleteFromProfile(),
        ).thenAnswer((_) async => complete);
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: navigatorKey,
            scaffoldMessengerKey: messengerKey,
            navigatorObservers: [coordinator],
            initialRoute: AppRoutes.verifyEmail,
            routes: {
              AppRoutes.splash: (_) => const Scaffold(),
              AppRoutes.verifyEmail:
                  (_) => const Scaffold(body: Text('Verify')),
              AppRoutes.startupRouter:
                  (_) => StartupRouterScreen(
                    onboardingRepository: repository,
                    testSession: _session,
                  ),
              AppRoutes.dashboard:
                  (_) => const Scaffold(body: Text('Dashboard')),
              AppRoutes.optNotifications:
                  (_) => const Scaffold(body: Text('Onboarding')),
            },
          ),
        );
        userId = 'user';
        events.add(AuthState(AuthChangeEvent.signedIn, _session));
        await tester.pumpAndSettle();
        expect(
          find.text(complete ? 'Dashboard' : 'Onboarding'),
          findsOneWidget,
        );
        verify(() => repository.fetchOnboardingCompleteFromProfile()).called(1);
      },
    );
  }
}
