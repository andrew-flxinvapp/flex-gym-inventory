import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/repositories/onboarding_repository.dart';
import '../../theme/app_theme.dart';
import 'package:flex_gym_inventory/utilities/logging_handler.dart';
import '../../routes/routes.dart';

/// Decides where the app should go on startup. Shared by [SplashScreen] and
/// [StartupRouterScreen] so the decision rules live in one place.
///
/// - No session → [AppRoutes.authLanding]
/// - Session + onboarding complete → [AppRoutes.dashboard]
/// - Session + onboarding incomplete → [AppRoutes.optNotifications]
Future<String> resolveStartupRoute({
  OnboardingRepository? onboardingRepository,
  Session? testSession,
}) async {
  // Prefer an injected test session to avoid touching Supabase in tests.
  final session =
      testSession ?? Supabase.instance.client.auth.currentSession;

  if (session == null) return AppRoutes.authLanding;

  final onboardingRepo = onboardingRepository ?? OnboardingRepository();

  // Determine onboarding completion from the canonical `public.profiles`
  // row. This avoids relying on auth.user_metadata which is legacy.
  bool onboardingComplete = false;
  try {
    onboardingComplete = await onboardingRepo.fetchOnboardingCompleteFromProfile();
  } catch (e, st) {
    LogHandler.warning('StartupRouter', 'Failed to fetch profile onboarding state: $e', e, st);
    onboardingComplete = false;
  }

  return onboardingComplete ? AppRoutes.dashboard : AppRoutes.optNotifications;
}

class StartupRouterScreen extends StatefulWidget {
  /// Optional injection point for `OnboardingRepository` to make the screen
  /// testable. If not provided, a default instance is created.
  const StartupRouterScreen({
    super.key,
    this.onboardingRepository,
    this.testSession,
  });

  final OnboardingRepository? onboardingRepository;

  /// Optional test-only session to allow tests to simulate an authenticated
  /// session without depending on `Supabase.instance`.
  final Session? testSession;

  @override
  State<StartupRouterScreen> createState() => _StartupRouterScreenState();
}

class _StartupRouterScreenState extends State<StartupRouterScreen> {
  StreamSubscription? _authSub;
  var _navigated = false;
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final target = await resolveStartupRoute(
      onboardingRepository: widget.onboardingRepository,
      testSession: widget.testSession,
    );

    if (!mounted) return;

    if (target == AppRoutes.authLanding) {
      // No session right now — listen for an auth state change so that when
      // the magic link flow restores a session we can navigate into the app.
      _authSub = Supabase.instance.client.auth.onAuthStateChange.listen(
        (event) {
          final newSession = event.session;
          if (newSession != null && !_navigated && mounted) {
            _navigated = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              Navigator.of(context).pushReplacementNamed(AppRoutes.startupRouter);
            });
          }
        },
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(target);
    });
  }

  @override
  Widget build(BuildContext context) {
    // This screen is basically invisible, just a tiny loading state.
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: const Center(child: CircularProgressIndicator.adaptive()),
    );
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
