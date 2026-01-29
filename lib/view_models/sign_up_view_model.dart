import 'package:flutter/material.dart';
import 'package:flex_gym_inventory/src/repositories/auth_repository.dart';
import 'package:flex_gym_inventory/src/models/ui_message.dart';

class SignUpViewModel extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final AuthRepository _authRepository;

  SignUpViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  bool _loading = false;
  UiMessage? _message;
  String? _emailError;
  String? _firstNameError;
  String? _lastNameError;

  bool get loading => _loading;
  UiMessage? get message => _message;
  String? get emailError => _emailError;
  String? get firstNameError => _firstNameError;
  String? get lastNameError => _lastNameError;

  Future<void> signUp({Map<String, dynamic>? userMetadata}) async {
    final email = emailController.text.trim();

    // Use the shared validator to keep messages/regex consistent.
    final valid = validateEmail();
    if (!valid) return;

    _setLoading(true);
    _setMessage(null);
    try {
      // Magic-link (OTP) only sign-up. Metadata cannot reliably be saved
      // during the magic-link flow across all Supabase setups, so we only
      // request the magic link here. Persist metadata after verification
      // using `AuthRepository.updateUserMetadata` when a session is active.
      await _authRepository.signUp(email);
      _setMessage(UiMessage('Sign up successful! Please check your email to verify your account.', type: UiMessageType.success));
    } on AuthException catch (ae) {
      _setMessage(UiMessage(ae.message ?? 'Sign up failed.', type: UiMessageType.error));
    } catch (e) {
      _setMessage(UiMessage('Error: ${e.toString()}', type: UiMessageType.error));
    } finally {
      _setLoading(false);
    }
  }

  /// Validate the current email value and set an appropriate message.
  /// Returns `true` when valid.
  bool validateEmail() {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      _emailError = 'Please enter your email';
      notifyListeners();
      return false;
    }
    final emailRegex = RegExp(r"^[^@\\s]+@[^@\\s]+\.[^@\\s]+");
    if (!emailRegex.hasMatch(email)) {
      _emailError = 'Please enter a valid email';
      notifyListeners();
      return false;
    }
    _emailError = null;
    notifyListeners();
    return true;
  }

  bool validateFirstName(String value) {
    final v = value.trim();
    if (v.isEmpty) {
      _firstNameError = null; // optional
      return true;
    }
    if (v.length < 2) {
      _firstNameError = 'Please enter a valid first name';
      notifyListeners();
      return false;
    }
    _firstNameError = null;
    notifyListeners();
    return true;
  }

  bool validateLastName(String value) {
    final v = value.trim();
    if (v.isEmpty) {
      _lastNameError = null; // optional
      return true;
    }
    if (v.length < 2) {
      _lastNameError = 'Please enter a valid last name';
      notifyListeners();
      return false;
    }
    _lastNameError = null;
    notifyListeners();
    return true;
  }

  void clearEmailError() {
    if (_emailError != null) {
      _emailError = null;
      notifyListeners();
    }
  }

  void clearFirstNameError() {
    if (_firstNameError != null) {
      _firstNameError = null;
      notifyListeners();
    }
  }

  void clearLastNameError() {
    if (_lastNameError != null) {
      _lastNameError = null;
      notifyListeners();
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
