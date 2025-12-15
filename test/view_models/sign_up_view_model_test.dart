import 'package:flutter_test/flutter_test.dart';
import 'package:flex_gym_inventory/src/repositories/auth_repository.dart';
import 'package:flex_gym_inventory/view_models/sign_up_view_model.dart';

class _RecordingAuthRepository extends AuthRepository {
  bool called = false;
  String? email;
  String? password;
  _RecordingAuthRepository() : super(client: null);

  @override
  Future<void> signUp(String email, {String? password}) async {
    called = true;
    this.email = email;
    this.password = password;
  }
}

class _SuccessfulAuthRepository extends AuthRepository {
  String? receivedEmail;
  String? receivedPassword;
  _SuccessfulAuthRepository() : super(client: null);

  @override
  Future<void> signUp(String email, {String? password}) async {
    receivedEmail = email;
    receivedPassword = password;
  }
}

class _ThrowingAuthRepository extends AuthRepository {
  final AuthException exception;
  _ThrowingAuthRepository(this.exception) : super(client: null);

  @override
  Future<void> signUp(String email, {String? password}) async {
    throw exception;
  }
}

void main() {
  test('empty email shows message and does not call repository', () async {
    final repo = _RecordingAuthRepository();
    final vm = SignUpViewModel(authRepository: repo);

    vm.emailController.text = '';
    vm.passwordController.text = 'password123';

    await vm.signUp();

    expect(vm.message, 'Please enter your email address.');
    expect(repo.called, isFalse);
  });

  test('invalid email shows validation message', () async {
    final repo = _RecordingAuthRepository();
    final vm = SignUpViewModel(authRepository: repo);

    vm.emailController.text = 'invalid-email';
    vm.passwordController.text = 'password123';

    await vm.signUp();

    expect(vm.message, 'Please enter a valid email address.');
    expect(repo.called, isFalse);
  });

  test('empty password shows message and does not call repository', () async {
    final repo = _RecordingAuthRepository();
    final vm = SignUpViewModel(authRepository: repo);

    vm.emailController.text = 'user@example.com';
    vm.passwordController.text = '';

    await vm.signUp();

    expect(vm.message, 'Please enter a password.');
    expect(repo.called, isFalse);
  });

  test('short password shows message and does not call repository', () async {
    final repo = _RecordingAuthRepository();
    final vm = SignUpViewModel(authRepository: repo);

    vm.emailController.text = 'user@example.com';
    vm.passwordController.text = 'short';

    await vm.signUp();

    expect(vm.message, 'Password must be at least 8 characters.');
    expect(repo.called, isFalse);
  });

  test('successful sign up calls repository and sets success message', () async {
    final repo = _SuccessfulAuthRepository();
    final vm = SignUpViewModel(authRepository: repo);

    vm.emailController.text = 'user@example.com';
    vm.passwordController.text = 'password123';

    await vm.signUp();

    expect(vm.message,
        'Sign up successful! Please check your email to verify your account.');
    expect(vm.loading, isFalse);
    expect(repo.receivedEmail, 'user@example.com');
    expect(repo.receivedPassword, 'password123');
  });

  test('repository throws AuthException and message is surfaced', () async {
    final repo = _ThrowingAuthRepository(
        AuthException(AuthError.invalidCredentials, 'bad credentials'));
    final vm = SignUpViewModel(authRepository: repo);

    vm.emailController.text = 'user@example.com';
    vm.passwordController.text = 'password123';

    await vm.signUp();

    expect(vm.message, 'bad credentials');
  });
}
