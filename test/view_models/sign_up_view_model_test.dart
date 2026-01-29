import 'package:flutter_test/flutter_test.dart';
import 'package:flex_gym_inventory/src/repositories/auth_repository.dart';
import 'package:flex_gym_inventory/view_models/sign_up_view_model.dart';

class _RecordingAuthRepository extends AuthRepository {
  bool called = false;
  String? email;
  _RecordingAuthRepository() : super(client: null);
  @override
  Future<void> signUp(String email) async {
    called = true;
    this.email = email;
  }
}

class _SuccessfulAuthRepository extends AuthRepository {
  String? receivedEmail;
  _SuccessfulAuthRepository() : super(client: null);
  @override
  Future<void> signUp(String email) async {
    receivedEmail = email;
  }
}

class _ThrowingAuthRepository extends AuthRepository {
  final AuthException exception;
  _ThrowingAuthRepository(this.exception) : super(client: null);
  @override
  Future<void> signUp(String email) async {
    throw exception;
  }
}

void main() {
  test('empty email shows message and does not call repository', () async {
    final repo = _RecordingAuthRepository();
    final vm = SignUpViewModel(authRepository: repo);

    vm.emailController.text = '';

    await vm.signUp();

    expect(vm.message?.title, 'Please enter your email address.');
    expect(repo.called, isFalse);
  });

  test('invalid email shows validation message', () async {
    final repo = _RecordingAuthRepository();
    final vm = SignUpViewModel(authRepository: repo);

    vm.emailController.text = 'invalid-email';

    await vm.signUp();

    expect(vm.message?.title, 'Please enter a valid email address.');
    expect(repo.called, isFalse);
  });

  test('empty password triggers magic-link signup via repository', () async {
    final repo = _RecordingAuthRepository();
    final vm = SignUpViewModel(authRepository: repo);

    vm.emailController.text = 'user@example.com';

    await vm.signUp();

    expect(repo.called, isTrue);
    expect(repo.email, 'user@example.com');
    expect(vm.message?.title,
      'Sign up successful! Please check your email to verify your account.');
  });
  test('successful sign up calls repository and sets success message', () async {
    final repo = _SuccessfulAuthRepository();
    final vm = SignUpViewModel(authRepository: repo);

    vm.emailController.text = 'user@example.com';

    await vm.signUp();

    expect(vm.message?.title,
      'Sign up successful! Please check your email to verify your account.');
    expect(vm.loading, isFalse);
    expect(repo.receivedEmail, 'user@example.com');
  });

  test('repository throws AuthException and message is surfaced', () async {
    final repo = _ThrowingAuthRepository(
        AuthException(AuthError.invalidCredentials, 'bad credentials'));
    final vm = SignUpViewModel(authRepository: repo);

    vm.emailController.text = 'user@example.com';

    await vm.signUp();

    expect(vm.message?.title, 'bad credentials');
  });
}
