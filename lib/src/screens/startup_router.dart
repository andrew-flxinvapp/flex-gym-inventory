import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/onboarding_repository.dart';
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

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final client = Supabase.instance.client;
    final session = widget.testSession ?? client.auth.currentSession;

    if (!mounted) return;

    if (session == null) {
      // No session → User not logged in → Go to Login / Sign Up screen
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      return;
    }

    // Session exists → check onboarding metadata and route accordingly.
    final onboardingRepo = widget.onboardingRepository ?? OnboardingRepository();
    final onboardingComplete = onboardingRepo.isOnboardingComplete;

    if (onboardingComplete) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
    } else {
      // Not complete — send the user into the onboarding flow.
      Navigator.of(context).pushReplacementNamed(AppRoutes.onboardingFeatureOne);
    }
  }

  @override
  Widget build(BuildContext context) {
    // This screen is basically invisible, just a tiny loading state.
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: const Center(
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }
}
