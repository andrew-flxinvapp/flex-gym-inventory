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
  final session = testSession ?? Supabase.instance.client.auth.currentSession;

  if (session == null) return AppRoutes.authLanding;

  final onboardingRepo = onboardingRepository ?? OnboardingRepository();

  // Determine onboarding completion from the canonical `public.profiles`
  // row. Lookup errors propagate so the screen can offer a retry rather than
  // treating a failed lookup as incomplete onboarding.
  final onboardingComplete =
      await onboardingRepo.fetchOnboardingCompleteFromProfile();

  return onboardingComplete ? AppRoutes.dashboard : AppRoutes.optNotifications;
}

class StartupRouterScreen extends StatefulWidget {
  /// Optional injection point for `OnboardingRepository` to make the screen
  /// testable. If not provided, a default instance is created.
  const StartupRouterScreen({
    super.key,
    this.onboardingRepository,
    this.testSession,
    this.startupTimeout = const Duration(seconds: 8),
  });

  final OnboardingRepository? onboardingRepository;

  /// Maximum time to wait for each startup resolution attempt.
  final Duration startupTimeout;

  /// Optional test-only session to allow tests to simulate an authenticated
  /// session without depending on `Supabase.instance`.
  final Session? testSession;

  @override
  State<StartupRouterScreen> createState() => _StartupRouterScreenState();
}

class _StartupRouterScreenState extends State<StartupRouterScreen> {
  StreamSubscription? _authSub;
  var _isResolving = false;
  var _navigationScheduled = false;
  var _authRedirectScheduled = false;
  var _hasError = false;
  var _requestGeneration = 0;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    if (_isResolving || _navigationScheduled) return;
    final requestGeneration = ++_requestGeneration;
    _isResolving = true;
    if (_hasError) {
      setState(() {
        _hasError = false;
      });
    }

    late final String target;
    try {
      target = await resolveStartupRoute(
        onboardingRepository: widget.onboardingRepository,
        testSession: widget.testSession,
      ).timeout(widget.startupTimeout);
    } catch (e, st) {
      LogHandler.warning(
        'StartupRouter',
        'Failed to fetch profile onboarding state: $e',
        e,
        st,
      );
      if (mounted && requestGeneration == _requestGeneration) {
        setState(() {
          _hasError = true;
        });
      }
      return;
    } finally {
      if (requestGeneration == _requestGeneration) {
        _isResolving = false;
      }
    }

    if (!mounted || requestGeneration != _requestGeneration) return;
    if (target == AppRoutes.authLanding) {
      // No session right now — listen for an auth state change so that when
      // the magic link flow restores a session we can navigate into the app.
      _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((
        event,
      ) {
        final newSession = event.session;
        if (newSession != null && !_authRedirectScheduled && mounted) {
          _authRedirectScheduled = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            Navigator.of(context).pushReplacementNamed(AppRoutes.startupRouter);
          });
        }
      });
    }

    _navigationScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (target == AppRoutes.authLanding && _authRedirectScheduled) return;
      Navigator.of(context).pushReplacementNamed(target);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        backgroundColor: AppTheme.lightBackground,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "We couldn't check your profile.",
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check your connection and try again.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isResolving ? null : _bootstrap,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

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
