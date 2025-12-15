import 'package:flutter/material.dart';
import 'package:flex_gym_inventory/src/repositories/auth_repository.dart';

class SignUpViewModel extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthRepository _authRepository;

  SignUpViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  bool _loading = false;
  String? _message;

  bool get loading => _loading;
  String? get message => _message;

  Future<void> signUp() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    // Basic client-side validation.
    if (email.isEmpty) {
      _setMessage('Please enter your email address.');
      return;
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      _setMessage('Please enter a valid email address.');
      return;
    }

    if (password.isEmpty) {
      _setMessage('Please enter a password.');
      return;
    }

    if (password.length < 8) {
      _setMessage('Password must be at least 8 characters.');
      return;
    }

    _setLoading(true);
    _setMessage(null);
    try {
      await _authRepository.signUp(email, password: password);
      _setMessage('Sign up successful! Please check your email to verify your account.');
    } on AuthException catch (ae) {
      _setMessage(ae.message ?? 'Sign up failed.');
    } catch (e) {
      _setMessage('Error: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void _setMessage(String? value) {
    _message = value;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
