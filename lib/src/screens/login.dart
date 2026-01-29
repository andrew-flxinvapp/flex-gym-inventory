import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../widgets/onboarding_topappbar.dart';
import '../widgets/buttons/primary_button.dart';
import '../../view_models/login_view_model.dart';
import 'package:flex_gym_inventory/routes/routes.dart';
import '../widgets/snackbar.dart';

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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loginViewModel.addListener(() {
      if (!mounted) return;
      final msg = _loginViewModel.message;
      if (msg != null) {
        showFlexSnackbarFromUiMessage(context, msg);
        _loginViewModel.clearMessage();
      }
      setState(() {});
    });
  }

  Future<void> _sendMagicLink() async {
    await _loginViewModel.sendMagicLink();
  }

  @override
  void dispose() {
    _loginViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: const OnboardingLogoAppBar(),
      body: SafeArea(
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
                      'lib/assets/images/waiting.png',
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
                  const SizedBox(height: 16),
                  Text(
                    'Email',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.lightTextPrimary,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Roboto',
                        ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextField(
                      controller: _loginViewModel.emailController,
                      onChanged: (_) => _loginViewModel.clearEmailError(),
                      decoration: InputDecoration(
                        hintText: 'flex@flxinv.com',
                        hintStyle: TextStyle(color: AppTheme.lightTextSecondary),
                        errorText: _loginViewModel.emailError,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(color: AppTheme.lightTextPrimary),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: _loginViewModel.loading ? 'Sending...' : 'Sign In',
                    onPressed: () {
                      if (_loginViewModel.loading) return;
                      if (_loginViewModel.validateEmail()) {
                        _sendMagicLink();
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
