import 'package:flutter/material.dart';
import 'package:flex_gym_inventory/src/repositories/auth_repository.dart';


class LoginViewModel extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final AuthRepository _authRepository;

  LoginViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  bool _loading = false;
  String? _message;

  bool get loading => _loading;
  String? get message => _message;

  Future<void> sendMagicLink() async {
    final email = emailController.text.trim();

    // Basic validation before calling the network layer.
    if (email.isEmpty) {
      _setMessage('Please enter your email address.');
      return;
    }

    // Simple email pattern — good enough for client-side validation.
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      _setMessage('Please enter a valid email address.');
      return;
    }

    _setLoading(true);
    _setMessage(null);
    try {
      await _authRepository.signInWithMagicLink(email);
      _setMessage('Magic link sent! Check your email.');
    } on AuthException catch (ae) {
      _setMessage(ae.message ?? 'Failed to send magic link');
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
