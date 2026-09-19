import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../theme/app_theme.dart';
import '../../constant/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/onboarding_topappbar.dart';
import 'package:flex_gym_inventory/routes/routes.dart';
import '../../view_models/sign_up_view_model.dart';
import '../utils/pending_metadata_store.dart';
import '../widgets/snackbar.dart';
import 'package:flex_gym_inventory/src/models/ui_message.dart';
import '../widgets/inputs/text_input_field.dart';

// SignupScreen
// This scree provides user registration entry.
// Follows MVVM architecture. Connect to a ViewModel for state management.

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Terms checkbox removed — users no longer need to toggle acceptance here.
  final SignUpViewModel _signUpViewModel = SignUpViewModel();
  TapGestureRecognizer? _termsTapRecognizer;
  TapGestureRecognizer? _privacyTapRecognizer;
  // Optional local controllers for additional profile fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  /// Kick off the sign-up flow using the view model.
  void _performSignUp() {
    if (_signUpViewModel.loading) return;
    () async {
      // Build user metadata from first/last name fields (omit empty values)
      final userMetadata = <String, dynamic>{};
      if (_firstNameController.text.trim().isNotEmpty) {
        userMetadata['first_name'] = _firstNameController.text.trim();
      }
      if (_lastNameController.text.trim().isNotEmpty) {
        userMetadata['last_name'] = _lastNameController.text.trim();
      }

      // Persist pending metadata locally so it can be reconciled after the
      // user completes the magic-link flow and a session exists.
      if (userMetadata.isNotEmpty) {
        await PendingMetadataStore.save(userMetadata);
      }

      // Trigger the view model sign-up which handles validation and network
      await _signUpViewModel.signUp();
    }();
  }

  @override
  void initState() {
    super.initState();
    _termsTapRecognizer = TapGestureRecognizer()
      ..onTap = () => _openLink(kTermsUrl);
    _privacyTapRecognizer = TapGestureRecognizer()
      ..onTap = () => _openLink(kPrivacyUrl);
    _signUpViewModel.addListener(() {
      if (!mounted) return;
      final msg = _signUpViewModel.message;
      if (msg != null) {
        showFlexSnackbarFromUiMessage(context, msg);
        // If sign-up succeeded, go to verify email screen. The email hasn't
        // necessarily been verified yet — this only confirms the link was sent.
        if (msg.type == UiMessageType.success) {
          Navigator.of(context).pushNamed(
            AppRoutes.verifyEmail,
            arguments: {'email': _signUpViewModel.emailController.text},
          );
        }
        _signUpViewModel.clearMessage();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _termsTapRecognizer?.dispose();
    _privacyTapRecognizer?.dispose();
    _signUpViewModel.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 16), // Add vertical space to bump the form down
              // Title
              Text(
                'Sign Up',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppTheme.lightTextPrimary,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
                textAlign: TextAlign.center,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // First Name TextField
                    SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomTextInputField(
                            hintText: 'First Name',
                            controller: _firstNameController,
                            height: 50,
                          ),
                          if (_signUpViewModel.firstNameError != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              _signUpViewModel.firstNameError!,
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Last Name TextField
                    SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomTextInputField(
                            hintText: 'Last Name',
                            controller: _lastNameController,
                            height: 50,
                          ),
                          if (_signUpViewModel.lastNameError != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              _signUpViewModel.lastNameError!,
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Email TextField with VM-driven inline error
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomTextInputField(
                          hintText: 'Email',
                          controller: _signUpViewModel.emailController,
                          keyboardType: TextInputType.emailAddress,
                          height: 50,
                        ),
                        if (_signUpViewModel.emailError != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            _signUpViewModel.emailError!,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text.rich(
                  TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTextPrimary,
                      fontFamily: 'Roboto',
                    ),
                    children: [
                      const TextSpan(text: "By continuing, you agree to Flex Gym Inventory's "),
                      TextSpan(
                        text: 'Terms',
                        style: TextStyle(
                          color: AppTheme.lightTextSecondary,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: _termsTapRecognizer,
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: AppTheme.lightTextSecondary,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: _privacyTapRecognizer,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              // Sign Up Button (always enabled, disabled while submitting)
              PrimaryButton(
                label: _signUpViewModel.loading ? 'Signing up...' : 'Sign Up',
                onPressed: _signUpViewModel.loading
                    ? null
                    : () {
                        final firstOk = _signUpViewModel.validateFirstName(
                          _firstNameController.text,
                        );
                        final lastOk = _signUpViewModel.validateLastName(
                          _lastNameController.text,
                        );
                        final emailOk = _signUpViewModel.validateEmail();
                        if (firstOk && lastOk && emailOk) {
                          _performSignUp();
                        }
                      },
              ),
              const SizedBox(height: 16),
              // Already have an account? Sign In link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTextPrimary,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.login);
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Sign In',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTextSecondary,
                        decoration: TextDecoration.underline,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
