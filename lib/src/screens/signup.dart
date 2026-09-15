import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/buttons/disabled_button.dart';
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
  bool _agreedToTerms = false;
  final SignUpViewModel _signUpViewModel = SignUpViewModel();
  // Optional local controllers for additional profile fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  /// Kick off the sign-up flow using the view model.
  void _performSignUp() {
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
    _signUpViewModel.addListener(() {
      if (!mounted) return;
      final msg = _signUpViewModel.message;
      if (msg != null) {
        showFlexSnackbarFromUiMessage(context, msg);
        // If sign-up succeeded, go to verify email screen.
        if (msg.type == UiMessageType.success) {
          Navigator.of(context).pushNamed(AppRoutes.verifyEmail);
        }
        _signUpViewModel.clearMessage();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _signUpViewModel.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 32), // Add vertical space to bump the form down
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
              const SizedBox(height: 16),
              Text(
                'Your gym. Your equipment. All in one place.',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.lightTextPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'Sign up below',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.lightTextPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              Spacer(flex: 1),
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
              const SizedBox(height: 16),
              // Checkbox for Terms and Conditions
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTextSecondary,
                      fontFamily: 'Roboto',
                    ),
                    children: [
                      const TextSpan(text: 'I accept the '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: GestureDetector(
                          onTap: () {
                            // TODO: Navigate to legal/settings page when implemented
                            // Use NavigationService or Navigator when route exists
                            // For now, log the tap
                            // LoggingHandler.log('Tapped Terms and Privacy Policy link');
                          },
                          child: Text(
                            'Terms and Privacy Policy',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              decoration: TextDecoration.underline,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                value: _agreedToTerms,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (bool? value) {
                  setState(() {
                    _agreedToTerms = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 16),
              // Sign Up Button
              _agreedToTerms
                  ? PrimaryButton(
                    label:
                        _signUpViewModel.loading ? 'Signing up...' : 'Sign Up',
                    onPressed: () {
                      if (_signUpViewModel.loading) return;
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
                  )
                  : DisabledButton(
                    label: 'Sign Up',
                    onPressed: () {}, // No-op when disabled
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
