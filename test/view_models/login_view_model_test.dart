import 'package:flutter_test/flutter_test.dart';
import 'package:flex_gym_inventory/src/repositories/auth_repository.dart';
import 'package:flex_gym_inventory/view_models/login_view_model.dart';

// Simple fake repositories implemented as subclasses so we don't need any
// external mocking dependency. Each override only implements
// signInWithMagicLink, which is what's used by the view model.
class _RecordingAuthRepository extends AuthRepository {
  bool called = false;
  String? email;
  _RecordingAuthRepository() : super(client: null);
  @override
  Future<void> signInWithMagicLink(String email) async {
    called = true;
    this.email = email;
  }
}

class _SuccessfulAuthRepository extends AuthRepository {
  String? receivedEmail;
  _SuccessfulAuthRepository() : super(client: null);
  @override
  Future<void> signInWithMagicLink(String email) async {
    receivedEmail = email;
  }
}

class _ThrowingAuthRepository extends AuthRepository {
  final AuthException exception;
  _ThrowingAuthRepository(this.exception) : super(client: null);
  @override
  Future<void> signInWithMagicLink(String email) async {
    throw exception;
  }
}

void main() {
  test('empty email shows message and does not call repository', () async {
    final repo = _RecordingAuthRepository();
    final vm = LoginViewModel(authRepository: repo);

    vm.emailController.text = '';

    await vm.sendMagicLink();

    expect(vm.message?.title, 'Please enter your email address.');
    expect(repo.called, isFalse);
  });

  test('valid email success sets message and calls repository', () async {
    final repo = _SuccessfulAuthRepository();
    final vm = LoginViewModel(authRepository: repo);

    vm.emailController.text = 'user@example.com';

    await vm.sendMagicLink();

    expect(vm.message?.title, 'Magic link sent! Check your email.');
    expect(vm.loading, isFalse);
    expect(repo.receivedEmail, 'user@example.com');
  });

  test('repository throws AuthException sets message from exception', () async {
    final repo = _ThrowingAuthRepository(
        AuthException(AuthError.notFound, 'not found'));
    final vm = LoginViewModel(authRepository: repo);

    vm.emailController.text = 'user@example.com';

    await vm.sendMagicLink();

    expect(vm.message?.title, 'not found');
  });
}
