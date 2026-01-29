import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../widgets/onboarding_topappbar.dart';
import '../../view_models/auth_view_model.dart';
import '../widgets/snackbar.dart';
import 'package:flex_gym_inventory/src/models/ui_message.dart';

// Verify Email Screen
// This screen instructs users to check their email for a magic link to continue sign in or sign up.
// It can optionally accept route arguments containing an email or params map.

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final AuthViewModel _authViewModel = AuthViewModel();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Read optional email from route arguments. The app may pass a Map of params
    // from the deeplink handler, or a plain String email. We handle both.
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null) {
      if (args is Map && args.containsKey('email')) {
        _authViewModel.emailController.text = args['email']?.toString() ?? '';
      } else if (args is String) {
        _authViewModel.emailController.text = args;
      } else if (args is Map<String, String> && args.containsKey('user_email')) {
        _authViewModel.emailController.text = args['user_email']!;
      }
    }
  }

  @override
  void dispose() {
    _authViewModel.dispose();
    super.dispose();
  }
  void initState() {
    super.initState();
    _authViewModel.addListener(() {
      if (!mounted) return;
      final msg = _authViewModel.message;
      if (msg != null) {
        showFlexSnackbarFromUiMessage(context, msg);
        _authViewModel.clearMessage();
      }
      setState(() {});
    });
  }

  Future<void> _resend() async {
    await _authViewModel.resendMagicLink();
  }

  @override
  Widget build(BuildContext context) {
    final emailLabel = _authViewModel.emailController.text.isNotEmpty
        ? _authViewModel.emailController.text
        : '(user-email)';

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
                  'We just emailed a magic link to $emailLabel. Check your email on this device to continue',
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
                const SizedBox(height: 8),
                // Resend magic link button at the bottom
                TextButton(
                  onPressed: _authViewModel.loading ? null : _resend,
                  child: Text(
                    _authViewModel.loading ? 'Resending...' : 'Resend magic link',
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