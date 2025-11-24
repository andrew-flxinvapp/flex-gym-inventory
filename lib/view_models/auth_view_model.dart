import 'package:flutter/material.dart';
import 'package:flex_gym_inventory/src/repositories/auth_repository.dart';

/// A small ChangeNotifier that wraps [AuthRepository] to provide
/// a single view-model for auth UI screens (login, signup, resend, signout).
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _loading = false;
  String? _message;

  bool get loading => _loading;
  String? get message => _message;

  /// Returns the current authenticated user object from the repository
  /// (may be `null` if not signed in).
  dynamic get currentUser => _authRepository.currentUser;

  Future<void> signInWithMagicLink() async {
    _setLoading(true);
    _setMessage(null);
    final email = emailController.text.trim();
    try {
      await _authRepository.signInWithMagicLink(email);
      _setMessage('Magic link sent — check your email.');
    } on AuthException catch (ae) {
      _setMessage(ae.message ?? 'Unable to send magic link');
    } catch (e) {
      _setMessage('Error: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUp() async {
    _setLoading(true);
    _setMessage(null);
    final email = emailController.text.trim();
    final password = passwordController.text.isNotEmpty
        ? passwordController.text
        : null;
    try {
      await _authRepository.signUp(email, password: password);
      _setMessage('Sign up successful. Check your email to verify.');
    } on AuthException catch (ae) {
      _setMessage(ae.message ?? 'Sign up failed');
    } catch (e) {
      _setMessage('Error: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resendMagicLink() async {
    _setLoading(true);
    _setMessage(null);
    final email = emailController.text.trim();
    try {
      await _authRepository.resendMagicLink(email);
      _setMessage('Magic link resent.');
    } on AuthException catch (ae) {
      _setMessage(ae.message ?? 'Unable to resend magic link');
    } catch (e) {
      _setMessage('Error: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    _setMessage(null);
    try {
      await _authRepository.signOut();
      _setMessage(null);
    } on AuthException catch (ae) {
      _setMessage(ae.message ?? 'Sign out failed');
    } catch (e) {
      _setMessage('Error: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void _setMessage(String? m) {
    _message = m;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
