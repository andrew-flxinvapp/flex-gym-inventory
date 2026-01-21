import 'package:flutter/material.dart';
import 'package:flex_gym_inventory/src/repositories/auth_repository.dart';

class SignUpViewModel extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final AuthRepository _authRepository;

  SignUpViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  bool _loading = false;
  String? _message;

  bool get loading => _loading;
  String? get message => _message;

  Future<void> signUp({Map<String, dynamic>? userMetadata}) async {
    final email = emailController.text.trim();

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

    _setLoading(true);
    _setMessage(null);
    try {
      // Magic-link (OTP) only sign-up. Metadata cannot reliably be saved
      // during the magic-link flow across all Supabase setups, so we only
      // request the magic link here. Persist metadata after verification
      // using `AuthRepository.updateUserMetadata` when a session is active.
      await _authRepository.signUp(email);
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
    super.dispose();
  }
}
