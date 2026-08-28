import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/onboarding_topappbar.dart';
import 'package:flex_gym_inventory/routes/routes.dart';
import '../data/repositories/onboarding_repository.dart';

class OnboardingCompleteScreen extends StatefulWidget {
  const OnboardingCompleteScreen({super.key, this.notificationsOn = false});

  final bool notificationsOn;

  @override
  State<OnboardingCompleteScreen> createState() =>
      _OnboardingCompleteScreenState();
}

class _OnboardingCompleteScreenState extends State<OnboardingCompleteScreen> {
  // Keep the repository as a per-state instance so it can be mocked in tests
  final OnboardingRepository _onboardingRepository = OnboardingRepository();

  // Submission state used to disable the button / show progress
  bool _isSubmitting = false;

  Future<void> _handleContinue() async {
    setState(() => _isSubmitting = true);
    try {
      await _onboardingRepository.completeOnboarding(
        notificationsOn: widget.notificationsOn,
      );
      // repository call completed; we don't navigate here to avoid
      // double-navigation — navigation is handled by the button tap.
    } catch (e) {
      // Optionally surface error to the user. For now, rethrow so callers/tests see it.
      rethrow;
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    // No resources to dispose currently, but keep the override for future use.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: const OnboardingLogoAppBar(
        showBackArrow: false,
        theme: OnboardingAppBarTheme.dark,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.9, -0.62),
            radius: 1.6,
            focal: Alignment(0.9, -0.7),
            focalRadius: 0.001,
            colors: [
              Color(0xFF1F4F66), // 0%
              Color(0xFF023246), // 28%
              Color(0xFF010D1B), // 64%
              Color(0xFF000000), // 100%
            ],
            stops: [0.0, 0.3, 0.8, 1.0],
            transform: GradientRotation(0.25),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.start, // Changed from center to start
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 32), // Added controlled top spacing
                Text(
                  'Onboarding Complete!',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppTheme.darkTextPrimary,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Image.asset(
                  'lib/assets/images/celebrate.png',
                  height: 325,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                Text(
                  'You completed onboarding! The button below will take you to your Dashboard!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.2,
                    color: AppTheme.darkTextPrimary,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 82),
                PrimaryButton(
                  label: 'To Dashboard',
                  variant: PrimaryButtonVariant.dark,
                  // keep a non-null callback (PrimaryButton requires it) but guard inside
                  onPressed: () {
                      if (_isSubmitting) return;
                      // Trigger repository work, but navigate immediately and
                      // replace onboarding in the stack with the dashboard.
                      _handleContinue();
                      Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
                    },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
