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
    _setLoading(true);
    _setMessage(null);
    final email = emailController.text.trim();
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
