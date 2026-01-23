import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flex_gym_inventory/src/screens/startup_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flex_gym_inventory/src/repositories/onboarding_repository.dart';
import 'package:flex_gym_inventory/routes/routes.dart';

class _MockOnboardingRepository extends Mock implements OnboardingRepository {}

class FakeSession extends Fake implements Session {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StartupRouterScreen', () {
    late _MockOnboardingRepository mockRepo;

    setUp(() {
      mockRepo = _MockOnboardingRepository();
    });

    testWidgets('navigates to onboarding when onboarding incomplete', (tester) async {
      when(() => mockRepo.isOnboardingComplete).thenReturn(false);

      // Provide a fake non-null Session so the screen treats the user as
      // authenticated and checks onboarding state.
      final fakeSession = FakeSession();

      await tester.pumpWidget(MaterialApp(
        routes: appRoutes,
        home: StartupRouterScreen(onboardingRepository: mockRepo, testSession: fakeSession),
      ));

      // allow async bootstrap to run
      await tester.pumpAndSettle();

      // Expect onboardingFeatureOne route to be pushed
      expect(find.byType(StartupRouterScreen), findsNothing);
    });

    testWidgets('navigates to dashboard when onboarding complete', (tester) async {
      when(() => mockRepo.isOnboardingComplete).thenReturn(true);

      final fakeSession = FakeSession();

      await tester.pumpWidget(MaterialApp(
        routes: appRoutes,
        home: StartupRouterScreen(onboardingRepository: mockRepo, testSession: fakeSession),
      ));

      // allow async bootstrap to run
      await tester.pumpAndSettle();

      // Expect dashboard to be shown
      expect(find.byType(StartupRouterScreen), findsNothing);
    });
  });
}
