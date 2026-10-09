import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../widgets/onboarding_topappbar.dart';
import '../widgets/buttons/primary_button.dart';
import '../../view_models/login_view_model.dart';
import 'package:flex_gym_inventory/routes/routes.dart';
import '../widgets/snackbar.dart';
import '../widgets/inputs/text_input_field.dart';
import '../widgets/layouts/app_screen.dart';

// LoginScreen
//
// This screen provides user authentication entry.
// Follows MVVM architecture. Connect to a ViewModel for state management.
//
// TODO: Connect to LoginViewModel and implement Riverpod for state management.
// TODO: Add responsive layout using size_config.dart.
// TODO: Add modular widgets for login form fields and actions.

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginViewModel _loginViewModel = LoginViewModel();

  @override
  void initState() {
    super.initState();

    // Listen for view model state changes to update UI and show messages
    _loginViewModel.addListener(() {
      if (!mounted) return;
      final msg = _loginViewModel.message;
      if (msg != null) {
        showFlexSnackbarFromUiMessage(context, msg);
        _loginViewModel.clearMessage();
      }
      setState(() {});
    });

    // Clear email error as the user types
    _loginViewModel.emailController.addListener(_onEmailChanged);
  }

  Future<void> _sendMagicLink() async {
    await _loginViewModel.sendMagicLink();
  }

  @override
  void dispose() {
    // Remove controller listener before disposing view model
    _loginViewModel.emailController.removeListener(_onEmailChanged);
    _loginViewModel.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    // Keep email error state in sync while typing
    _loginViewModel.clearEmailError();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: const OnboardingLogoAppBar(),
      body: AppScreen(
        safeArea: true,
        unfocusOnTap: true,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'Sign In',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppTheme.lightTextPrimary,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Image.asset(
                      'lib/assets/images/new_waiting.png',
                      height: 350,
                      width: 350,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your gym is waiting!',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.lightTextPrimary,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Roboto',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextInputField(
                          hintText: 'flex@flxinv.com',
                          controller: _loginViewModel.emailController,
                          keyboardType: TextInputType.emailAddress,
                          width: double.infinity,
                          height: 56,
                        ),
                        if (_loginViewModel.emailError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, left: 6.0),
                            child: Text(
                              _loginViewModel.emailError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: _loginViewModel.loading ? 'Sending...' : 'Sign In',
                    onPressed: () async {
                      if (_loginViewModel.loading) return;

                      // Trim whitespace and update controller
                      final trimmed = _loginViewModel.emailController.text.trim();
                      _loginViewModel.emailController.text = trimmed;

                      // Dismiss keyboard
                      FocusScope.of(context).unfocus();

                      if (_loginViewModel.validateEmail()) {
                        // Start sending magic link (don't await so navigation isn't blocked)
                        _sendMagicLink();

                        // Navigate to verify email screen and pass the trimmed email
                        Navigator.of(context).pushNamed(
                          AppRoutes.verifyEmail,
                          arguments: {'email': trimmed},
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don’t have an account? ",
                        style: TextStyle(
                          color: AppTheme.lightTextPrimary,
                          fontSize: 16,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(AppRoutes.signup);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: AppTheme.lightTextSecondary,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
