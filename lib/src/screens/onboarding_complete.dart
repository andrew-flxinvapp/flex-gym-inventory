import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/layouts/onboarding_bottom_action_layout.dart';
import '../widgets/onboarding_topappbar.dart';
import 'package:flex_gym_inventory/routes/routes.dart';
import '../data/repositories/onboarding_repository.dart';
import 'package:flex_gym_inventory/providers/profile_data_provider.dart';
import '../../service/pending_onboarding_profile_service.dart';

class OnboardingCompleteScreen extends ConsumerStatefulWidget {
  const OnboardingCompleteScreen({super.key});

  @override
  ConsumerState<OnboardingCompleteScreen> createState() =>
      _OnboardingCompleteScreenState();
}

class _OnboardingCompleteScreenState
    extends ConsumerState<OnboardingCompleteScreen> {
  // Keep the repository as a per-state instance so it can be mocked in tests
  final OnboardingRepository _onboardingRepository = OnboardingRepository();

  // Submission state used to disable the button / show progress
  bool _isSubmitting = false;

  Future<bool> _handleContinue() async {
    if (_isSubmitting) return false;
    setState(() => _isSubmitting = true);
    try {
      // Read profile data collected during signup/onboarding from the
      // in-memory provider.
      final profile = ref.read(profileDataProvider);
      // Require authenticated user before attempting the upsert.
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user for onboarding');
      }

      final pendingNames = await PendingOnboardingProfileService.load(
        user.email,
      );
      if (!mounted) return false;

      final profileBelongsToUser = profile.belongsToEmail(user.email);
      final savedFirstName = pendingNames?.firstName.trim();
      final savedLastName = pendingNames?.lastName.trim();
      final firstName =
          savedFirstName != null && savedFirstName.isNotEmpty
              ? savedFirstName
              : profileBelongsToUser
              ? profile.firstName?.trim()
              : null;
      final lastName =
          savedLastName != null && savedLastName.isNotEmpty
              ? savedLastName
              : profileBelongsToUser
              ? profile.lastName?.trim()
              : null;
      final bool notificationsOn = profile.notificationsOn == true;

      // Validate required name values before upsert.
      if (firstName == null || firstName.isEmpty || firstName.length < 2) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please provide a valid first name.')),
          );
        }
        return false;
      }
      if (lastName == null || lastName.isEmpty || lastName.length < 2) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please provide a valid last name.')),
          );
        }
        return false;
      }

      await _onboardingRepository.completeOnboarding(
        notificationsOn: notificationsOn,
        firstName: firstName,
        lastName: lastName,
      );

      if (!mounted) return false;
      // Clear in-memory profile data only after successful upsert.
      ref.read(profileDataProvider.notifier).clear();
      await PendingOnboardingProfileService.clear(user.email);
      // repository call completed; we don't navigate here to avoid
      // double-navigation — navigation is handled by the button tap.
      return true;
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
        child: OnboardingBottomActionLayout(
          content: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
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
                  'lib/assets/images/new_complete.png',
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
              ],
            ),
          ),
          action: PrimaryButton(
            label: 'To Dashboard',
            variant: PrimaryButtonVariant.dark,
            onPressed: () async {
              if (_isSubmitting) return;
              try {
                final completed = await _handleContinue();
                if (!completed || !context.mounted) return;
                Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Failed to complete onboarding. Please try again.',
                      ),
                    ),
                  );
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
