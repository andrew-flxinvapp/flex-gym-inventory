import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/repositories/onboarding_repository.dart';
import '../../theme/app_theme.dart';
import '../../routes/routes.dart';

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
    // Prefer an injected test session to avoid touching Supabase in tests.
    Session? session = widget.testSession;
    if (session == null) {
      final client = Supabase.instance.client;
      session = client.auth.currentSession;
    }

    if (!mounted) return;

    if (session == null) {
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

      // No session → User not logged in → Go to Login / Sign Up screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      });
      return;
    }

    // Session exists → check onboarding metadata and route accordingly.
    final onboardingRepo =
        widget.onboardingRepository ?? OnboardingRepository();
    final onboardingComplete = onboardingRepo.isOnboardingComplete;

    if (onboardingComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
      });
    } else {
      // Not complete — send the user into the onboarding flow.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(
          context,
        ).pushReplacementNamed(AppRoutes.optNotifications);
      });
    }
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
