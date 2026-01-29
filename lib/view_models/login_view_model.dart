import 'package:flutter/material.dart';
import 'package:flex_gym_inventory/src/repositories/auth_repository.dart';
import 'package:flex_gym_inventory/src/models/ui_message.dart';


class LoginViewModel extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final AuthRepository _authRepository;

  LoginViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  bool _loading = false;
  UiMessage? _message;
  String? _emailError;

  bool get loading => _loading;
  UiMessage? get message => _message;
  String? get emailError => _emailError;

  Future<void> sendMagicLink() async {
    final email = emailController.text.trim();

    // Basic validation before calling the network layer.
    if (!validateEmail()) return;

    _setLoading(true);
    _setMessage(null);
    try {
      await _authRepository.signInWithMagicLink(email);
      _setMessage(UiMessage('Magic link sent! Check your email.', type: UiMessageType.success));
    } on AuthException catch (ae) {
      _setMessage(UiMessage(ae.message ?? 'Failed to send magic link', type: UiMessageType.error));
    } catch (e) {
      _setMessage(UiMessage('Error: ${e.toString()}', type: UiMessageType.error));
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void _setMessage(UiMessage? value) {
    _message = value;
    notifyListeners();
  }

  /// Validate current email and set _emailError when invalid.
  bool validateEmail() {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      _emailError = 'Please enter your email';
      notifyListeners();
      return false;
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+');
    if (!emailRegex.hasMatch(email)) {
      _emailError = 'Please enter a valid email';
      notifyListeners();
      return false;
    }
    _emailError = null;
    notifyListeners();
    return true;
  }

  void clearEmailError() {
    if (_emailError != null) {
      _emailError = null;
      notifyListeners();
    }
  }

  /// Clear the current message after the UI has consumed it.
  void clearMessage() {
    _message = null;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
