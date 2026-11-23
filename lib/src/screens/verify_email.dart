import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_mail/open_mail.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_theme.dart';
import '../widgets/onboarding_topappbar.dart';
import '../../view_models/auth_view_model.dart';
import '../widgets/snackbar.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/layouts/app_screen.dart';

// Verify Email Screen
// This screen instructs users to check their email for a magic link to continue sign in or sign up.
// It can optionally accept route arguments containing an email or params map.

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final AuthViewModel _authViewModel = AuthViewModel();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Read optional email from route arguments. The app may pass a Map of params
    // from the deeplink handler, or a plain String email. We handle both.
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null) {
      if (args is Map && args.containsKey('email')) {
        _authViewModel.emailController.text = args['email']?.toString() ?? '';
      } else if (args is String) {
        _authViewModel.emailController.text = args;
      } else if (args is Map<String, String> &&
          args.containsKey('user_email')) {
        _authViewModel.emailController.text = args['user_email']!;
      }
    }
  }

  @override
  void dispose() {
    _authViewModel.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _authViewModel.addListener(() {
      if (!mounted) return;
      final msg = _authViewModel.message;
      if (msg != null) {
        showFlexSnackbarFromUiMessage(context, msg);
        _authViewModel.clearMessage();
      }
      setState(() {});
    });
  }

  Future<void> _resend() async {
    await _authViewModel.resendMagicLink();
  }

  Future<void> _openMailApp() async {
    try {
      final result = await OpenMail.openMailApp();
      if (!mounted || result.didOpen) return;

      if (result.canOpen) {
        final selectedApp = await _selectMailApp(result.options);
        if (!mounted || selectedApp == null) return;

        final selectedResult = await OpenMail.openSpecificMailApp(
          selectedApp.name,
        );
        if (!mounted || selectedResult.didOpen) return;
      }

      _showMailAppError('Please open your email app to find the sign-in link.');
    } on PlatformException catch (error) {
      if (!mounted) return;
      _showMailAppError(
        error.message ?? 'Please open your email app manually.',
      );
    } on MissingPluginException {
      if (!mounted) return;
      _showMailAppError('Please open your email app manually.');
    } on UnsupportedError {
      if (!mounted) return;
      _showMailAppError('Opening a mail app is not supported on this device.');
    }
  }

  Future<MailApp?> _selectMailApp(List<MailApp> apps) {
    return showDialog<MailApp>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppTheme.lightCard,
            title: Text(
              'Choose an email app',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppTheme.lightTextPrimary,
              ),
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: apps.length,
                itemBuilder: (context, index) {
                  final app = apps[index];
                  return ListTile(
                    title: Text(
                      app.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTextPrimary,
                      ),
                    ),
                    onTap: () => Navigator.of(context).pop(app),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTextPrimary,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showMailAppError(String message) {
    showFlexSnackbar(
      context,
      title: 'Unable to open mail app',
      subtitle: message,
      type: SnackbarType.stop,
    );
  }

  @override
  Widget build(BuildContext context) {
    final enteredEmail = _authViewModel.emailController.text.trim();
    final emailLabel = enteredEmail.isNotEmpty ? enteredEmail : 'your email';

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: const OnboardingLogoAppBar(),
      body: AppScreen(
        safeArea: true,
        lightSystemUi: false,
        child: LayoutBuilder(
          builder:
              (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Image.asset(
                            AppIcons.email,
                            height: 128,
                            width: 128,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Check your email',
                          style: Theme.of(
                            context,
                          ).textTheme.displayMedium?.copyWith(
                            color: AppTheme.lightTextPrimary,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text.rich(
                          TextSpan(
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.lightTextPrimary,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Roboto',
                            ),
                            children: [
                              const TextSpan(text: 'We sent an email to '),
                              TextSpan(
                                text: emailLabel,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(
                                text: '.\nIt has a link that will sign you in.',
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        PrimaryButton(
                          label: 'Open Mail App',
                          onPressed: _openMailApp,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Can't find our email? Check your spam folder!",
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.lightTextPrimary,
                            fontWeight: FontWeight.normal,
                            fontFamily: 'Roboto',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        TextButton(
                          onPressed: _authViewModel.loading ? null : _resend,
                          style: TextButton.styleFrom(
                            minimumSize: const Size(0, 48),
                            tapTargetSize: MaterialTapTargetSize.padded,
                          ),
                          child: Text(
                            _authViewModel.loading
                                ? 'Resending...'
                                : 'Resend magic link',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.lightTextPrimary,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        ),
      ),
    );
  }
}
