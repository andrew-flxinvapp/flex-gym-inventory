import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
//import '../widgets/buttons/primary_button.dart';
//import '../widgets/buttons/disabled_button.dart';
import '../widgets/onboarding_topappbar.dart';

// Verifiy Email Screen
// This screen instrucets users to check their email for a magic link to continue sign in or sign up.
// Follows MVVM architecture. Connect to a ViewModel for state management.

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: const OnboardingLogoAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                // Title
                Text(
                  'Verify Email',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppTheme.lightTextPrimary,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Mascot image
                Center(
                  child: Image.asset(
                    'lib/assets/images/check_email.png',
                    height: 350,
                    width: 350,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 8),
                // Subtitle
                Text(
                  'We just emailed a magic link to (user-email). Check your email on this device to continue', //use $email to insert the user's email
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.lightTextPrimary,
                        fontWeight: FontWeight.normal,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Didn't receive a link text
                Text(
                  "Didn't receive a link?",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.lightTextPrimary,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Roboto',
                      ),
                  textAlign: TextAlign.center,
                ),
                // Resend magic link button at the bottom
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/opt-notifications'); // Navigate to the next screen
                  },
                  child: Text(
                    'Resend magic link',
                    style: TextStyle(
                      color: AppTheme.lightTextPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}