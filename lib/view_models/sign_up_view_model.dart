import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpViewModel extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
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
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );
      if (response.user != null) {
        _setMessage('Sign up successful! Please check your email to verify your account.');
      } else {
        _setMessage('Sign up failed.');
      }
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
