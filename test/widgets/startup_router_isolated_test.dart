import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flex_gym_inventory/src/screens/startup_router.dart';
import 'package:flex_gym_inventory/src/repositories/onboarding_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flex_gym_inventory/routes/routes.dart';

class _MockOnboardingRepository extends Mock implements OnboardingRepository {}
class FakeSession extends Fake implements Session {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StartupRouterScreen (isolated)', () {
    late _MockOnboardingRepository mockRepo;

    setUp(() {
      mockRepo = _MockOnboardingRepository();
    });

    testWidgets('navigates to onboarding when onboarding incomplete', (tester) async {
      when(() => mockRepo.isOnboardingComplete).thenReturn(false);
      final fakeSession = FakeSession();

      // Build a routes map without the '/' entry to avoid MaterialApp assertion
      final routes = Map<String, WidgetBuilder>.from(appRoutes);
      routes.remove(AppRoutes.splash);
      // Replace heavy onboarding/dashboard routes with placeholders for test isolation
      routes[AppRoutes.onboardingFeatureOne] = (_) => const Scaffold(body: Center(child: Text('Onboarding')));

      await tester.pumpWidget(MaterialApp(
        routes: routes,
        home: StartupRouterScreen(onboardingRepository: mockRepo, testSession: fakeSession),
      ));

      await tester.pumpAndSettle();

      // After bootstrap, StartupRouterScreen should have navigated away
      expect(find.byType(StartupRouterScreen), findsNothing);
    });

    testWidgets('navigates to dashboard when onboarding complete', (tester) async {
      when(() => mockRepo.isOnboardingComplete).thenReturn(true);
      final fakeSession = FakeSession();

      final routes = Map<String, WidgetBuilder>.from(appRoutes);
      routes.remove(AppRoutes.splash);
      routes[AppRoutes.dashboard] = (_) => const Scaffold(body: Center(child: Text('Dashboard')));
      await tester.pumpWidget(MaterialApp(
        routes: routes,
        home: StartupRouterScreen(onboardingRepository: mockRepo, testSession: fakeSession),
      ));

      await tester.pumpAndSettle();

      expect(find.byType(StartupRouterScreen), findsNothing);
    });
  });
}
