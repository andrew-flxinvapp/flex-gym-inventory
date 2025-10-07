import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../widgets/onboarding_topappbar.dart';
import '../widgets/buttons/primary_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flex_gym_inventory/routes/routes.dart';

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
  final TextEditingController _emailController = TextEditingController();
  bool _loading = false;
  String? _message;

  Future<void> _sendMagicLink() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    final email = _emailController.text.trim();
    try {
      await Supabase.instance.client.auth.signInWithOtp(email: email);
      setState(() {
        _message = 'Magic link sent! Check your email.';
      });
    } catch (e) {
      setState(() {
        _message = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
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
                    height: 50,
                    child: TextField(
                      controller: _emailController,
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
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: _loading ? 'Sending...' : 'Sign In',
                    onPressed: () {
                      if (!_loading) {
                        _sendMagicLink();
                      }
                    },
                  ),
                  if (_message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _message!,
                      style: TextStyle(
                        color: _message!.startsWith('Error') ? Colors.red : Colors.green,
                        fontSize: 16,
                        fontFamily: 'Roboto',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
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
