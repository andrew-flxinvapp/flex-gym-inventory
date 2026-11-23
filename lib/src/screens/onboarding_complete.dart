import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import '../widgets/layouts/app_screen.dart';
import '../widgets/animations/animated_completion_icon.dart';
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
      body: AppScreen(
        useGradient: true,
        safeArea: true,
        lightSystemUi: true,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder:
                      (context, constraints) => SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 24,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const AnimatedCompletionIcon(),
                                const SizedBox(height: 24),
                                Text(
                                  "You're all set!",
                                  style: Theme.of(
                                    context,
                                  ).textTheme.displayMedium?.copyWith(
                                    color: AppTheme.darkTextPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Your gym inventory is ready.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.darkTextPrimary,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightBackground,
                      foregroundColor: AppTheme.lightTextPrimary,
                      minimumSize: const Size(0, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppTheme.darkBackground),
                      ),
                    ),
                    onPressed: () async {
                      if (_isSubmitting) return;
                      try {
                        final completed = await _handleContinue();
                        if (!completed || !context.mounted) return;
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.dashboard,
                          (route) => false,
                        );
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
                    child: Text(
                      'To Dashboard',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.lightTextPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
