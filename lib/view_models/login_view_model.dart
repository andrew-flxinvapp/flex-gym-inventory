import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginViewModel extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  bool _loading = false;
  String? _message;

  bool get loading => _loading;
  String? get message => _message;

  Future<void> sendMagicLink() async {
    _setLoading(true);
    _setMessage(null);
    final email = emailController.text.trim();
    try {
      await Supabase.instance.client.auth.signInWithOtp(email: email);
      _setMessage('Magic link sent! Check your email.');
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
