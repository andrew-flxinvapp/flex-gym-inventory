import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// LoginScreen
/// 
/// This screen provides user authentication entry.
/// Follows MVVM architecture. Connect to a ViewModel for state management.
/// 
/// TODO: Connect to LoginViewModel and implement Riverpod for state management.
/// TODO: Add responsive layout using size_config.dart.
/// TODO: Add modular widgets for login form fields and actions.

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 50), // Spacer from top of device to logo
                // Logo at the top
                SvgPicture.asset(
                  'lib/assets/images/fgi_logo.svg',
                  height: 50.87,
                  width: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 80),
                // Title
                Text(
                  'Login',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppTheme.lightTextPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 45),
                // Email TextField
                SizedBox(
                  width: 370,
                  height: 50,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Email',
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
                const SizedBox(height: 16),
                // Password TextField
                SizedBox(
                  width: 370,
                  height: 50,
                  child: TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password',
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
                const SizedBox(height: 8),
                // Forgot Password link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: AppTheme.lightTextSecondary,
                        decoration: TextDecoration.underline,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Login Button
                SizedBox(
                  width: 370,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Button',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Divider with text
                Row(
                  children: [
                    const Expanded(
                      child: Divider(
                        color: AppTheme.lightTextPrimary,
                        thickness: 1,
                        endIndent: 8,
                      ),
                    ),
                    Text(
                      'Sign in with',
                      style: TextStyle(
                        color: AppTheme.lightTextPrimary,
                        fontSize: 16,
                      ),
                    ),
                    const Expanded(
                      child: Divider(
                        color: AppTheme.lightTextPrimary,
                        thickness: 1,
                        indent: 8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Google Button
                SizedBox(
                  width: 370,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.g_mobiledata, size: 28, color: AppTheme.lightPrimary),
                    label: const Text(
                      'Google',
                      style: TextStyle(
                        color: AppTheme.lightPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.lightPrimary, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Apple Button
                SizedBox(
                  width: 370,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.apple, size: 28, color: AppTheme.lightPrimary),
                    label: const Text(
                      'Apple',
                      style: TextStyle(
                        color: AppTheme.lightPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.lightPrimary, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Sign Up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: AppTheme.lightTextPrimary,
                        fontSize: 16,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: AppTheme.lightTextSecondary,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
