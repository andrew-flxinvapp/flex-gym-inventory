import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/buttons/disabled_button.dart';
import '../widgets/onboarding_topappbar.dart';
import 'package:flex_gym_inventory/routes/routes.dart';
import '../../view_models/auth_view_model.dart';

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
  final AuthViewModel _authViewModel = AuthViewModel();
  bool _loading = false;
  String? _message;

  /// Kick off the sign-up flow using the view model.
  void _performSignUp() {
    // fire-and-forget from a sync callback so we can satisfy VoidCallback
    () async {
      setState(() {
        _loading = true;
        _message = null;
      });
      try {
        await _authViewModel.signUp();
        _message = _authViewModel.message;
                                    // On success, navigate to verify email screen
                                    if (!mounted) return;
                                    Navigator.of(context).pushNamed(AppRoutes.verifiyEmail);
      } catch (e) {
        _message = 'Error: ${e.toString()}';
      } finally {
        setState(() {
          _loading = false;
        });
      }
                                  if (_message != null) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(_message!)),
                                    );
                                  }
    }();
  }

  @override
  void dispose() {
    _authViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: const OnboardingLogoAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 48), // Add vertical space to bump the form down
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
                  // First Name Label
                  Text(
                    'First Name',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.lightTextPrimary,
                          fontFamily: 'Roboto',
                        ),
                  ),
                  const SizedBox(height: 8),
                  // First Name TextField
                  SizedBox(
                    height: 50,
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor: AppTheme.lightCard,
                        hintText: 'Flex',
                        hintStyle: TextStyle(color: AppTheme.lightTextSecondary),
                        contentPadding: EdgeInsets.symmetric(horizontal: 24),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Last Name Label
                  Text(
                    'Last Name',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.lightTextPrimary,
                          fontFamily: 'Roboto',
                        ),
                  ),
                  const SizedBox(height: 8),
                  // Last Name TextField
                  SizedBox(
                    height: 50,
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor: AppTheme.lightCard,
                        hintText: 'Rackley',
                        hintStyle: TextStyle(color: AppTheme.lightTextSecondary),
                        contentPadding: EdgeInsets.symmetric(horizontal: 24),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Email Label
                  Text(
                    'Email',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.lightTextPrimary,
                          fontFamily: 'Roboto',
                        ),
                  ),
                  const SizedBox(height: 8),
                  // Email TextField
                  SizedBox(
                    height: 50,
                    child: TextField(
                      controller: _authViewModel.emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor: AppTheme.lightCard,
                        hintText: 'flex@flxinv.com',
                        hintStyle: TextStyle(color: AppTheme.lightTextSecondary),
                        contentPadding: EdgeInsets.symmetric(horizontal: 24),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
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
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                          label: _loading ? 'Signing up...' : 'Sign Up',
                          onPressed: () {
                            if (_loading) return;
                            _performSignUp();
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
              )),
        ),
      ),
    );
  }
}