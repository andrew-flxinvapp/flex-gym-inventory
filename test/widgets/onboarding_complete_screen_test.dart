import 'package:flex_gym_inventory/routes/routes.dart';
import 'package:flex_gym_inventory/src/widgets/animations/animated_completion_icon.dart';
import 'package:flex_gym_inventory/src/screens/onboarding_complete.dart';
import 'package:flex_gym_inventory/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      publishableKey: 'test-anon-key',
      authOptions: const FlutterAuthClientOptions(
        autoRefreshToken: false,
        persistSession: false,
        detectSessionInUri: false,
      ),
    );
  });

  testWidgets(
    'completion layout remains accessible and preserves failure flow',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 568);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            builder:
                (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: const TextScaler.linear(2)),
                  child: child!,
                ),
            home: const OnboardingCompleteScreen(),
            routes: {
              AppRoutes.dashboard:
                  (_) => const Scaffold(body: Text('Dashboard destination')),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      final illustration = find.byType(AnimatedCompletionIcon);
      final heading = find.text("You're all set!");
      expect(illustration, findsOneWidget);
      expect(
        tester
            .widget<ElevatedButton>(
              find.widgetWithText(ElevatedButton, 'To Dashboard'),
            )
            .onPressed,
        isNotNull,
      );
      expect(heading, findsOneWidget);
      expect(
        tester.getTopLeft(illustration).dy,
        lessThan(tester.getTopLeft(heading).dy),
      );
      await tester.ensureVisible(find.text('Your gym inventory is ready.'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('To Dashboard'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(
        find.text('Failed to complete onboarding. Please try again.'),
        findsOneWidget,
      );
      expect(find.text('Dashboard destination'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
