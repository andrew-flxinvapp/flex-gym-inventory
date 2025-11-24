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
    _setLoading(true);
    _setMessage(null);
    final email = emailController.text.trim();
    final password = passwordController.text;
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
