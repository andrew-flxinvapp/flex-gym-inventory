import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/onboarding_topappbar.dart';
import 'package:flex_gym_inventory/routes/routes.dart';
import '../repositories/onboarding_repository.dart';

class OnboardingCompleteScreen extends StatefulWidget {
  const OnboardingCompleteScreen({
    super.key,
    required this.notificationsOn,
    required this.didUserBuyPro,
  });

  final bool notificationsOn;
  final bool didUserBuyPro;

  @override
  State<OnboardingCompleteScreen> createState() => _OnboardingCompleteScreenState();
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
        proPlan: widget.didUserBuyPro,
      );

      if (!mounted) return;
      Navigator.of(context).pushNamed(AppRoutes.dashboard);
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
      backgroundColor: AppTheme.lightBackground,
      appBar: const OnboardingLogoAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // Changed from center to start
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32), // Added controlled top spacing
              Text(
                'Onboarding Complete!',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppTheme.lightTextPrimary,
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
                  color: AppTheme.lightTextPrimary,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 82),
                PrimaryButton(
                  label: 'To Dashboard',
                  // keep a non-null callback (PrimaryButton requires it) but guard inside
                  onPressed: () {
                    if (_isSubmitting) return;
                    _handleContinue();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}