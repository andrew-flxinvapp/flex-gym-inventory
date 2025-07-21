import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../widgets/onboarding_topappbar.dart';
import '../widgets/buttons/primary_button.dart';

// LoginScreen
// 
// This screen provides user authentication entry.
// Follows MVVM architecture. Connect to a ViewModel for state management.
// 
// TODO: Connect to LoginViewModel and implement Riverpod for state management.
// TODO: Add responsive layout using size_config.dart.
// TODO: Add modular widgets for login form fields and actions.

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: const OnboardingLogoAppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 24), // Add vertical space to bump the form down
                // Title
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
                // Flex Rackley Waiting image
                Center(
                  child: Image.asset(
                    'lib/assets/images/waiting.png',
                    height: 350,
                    width: 350,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 8),
                // Subtitle
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
                // Email label
                Text(
                  'Email',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.lightTextPrimary,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Roboto',
                      ),
                ),
                const SizedBox(height: 8),
                // Email TextField
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'flex@flxinv.com',
                      hintStyle: TextStyle(color: AppTheme.lightTextSecondary),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: AppTheme.lightTextPrimary),
                  ),
                ),
                const SizedBox(height: 16
                ),
                // Sign In Button
                PrimaryButton(
                  label: 'Sign In',
                  onPressed: () {
                    // Get the email from the TextField controller
                    final emailController = TextEditingController();
                    // Navigate to the VerifyEmailScreen and pass the email
                    Navigator.of(context).pushNamed(
                      '/verify-email',
                      arguments: emailController.text,
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Sign Up link
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
                        Navigator.of(context).pushNamed('/signup');
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
    );
  }
}
