import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/inputs/text_input_field.dart';
import '../widgets/inputs/multiline_text_input.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/buttons/secondary_button.dart';
import '../widgets/snackbar.dart';

import '../data/dtos/feedback_dto.dart';
import '../../service/feedback_service.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isSubmitting = false;

  final FeedbackService _feedbackService = FeedbackService();

  static const int _messageMaxLength = 2000;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_enforceMessageMaxLength);
  }

  @override
  void dispose() {
    _messageController.removeListener(_enforceMessageMaxLength);
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _enforceMessageMaxLength() {
    final text = _messageController.text;
    if (text.length > _messageMaxLength) {
      final truncated = text.substring(0, _messageMaxLength);
      _messageController.value = _messageController.value.copyWith(
        text: truncated,
        selection: TextSelection.collapsed(offset: truncated.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: const TopAppBar(
        title: 'Feedback',
        showBackArrow: true,
        showRightIcon: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'We value your feedback.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Share your feedback with us to help improve your experience. We typically reply within 48 hours.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.normal,
                    color: AppTheme.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 32),
                CustomTextInputField(
                  hintText: 'Name',
                  showAsterisk: true,
                  controller: _nameController,
                  validator: (s) => s == null || s.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                CustomTextInputField(
                  hintText: 'Email',
                  showAsterisk: true,
                  controller: _emailController,
                  validator: (s) {
                    if (s == null || s.trim().isEmpty) return 'Required';
                    final email = s.trim();
                    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+');
                    if (!emailRegex.hasMatch(email)) return 'Invalid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextInputField(
                  hintText: 'Subject',
                  showAsterisk: true,
                  controller: _subjectController,
                  validator: (s) => s == null || s.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                CustomMultilineTextInput(
                  hintText: 'Message',
                  showAsterisk: true,
                  controller: _messageController,
                  validator: (s) => s == null || s.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 4),
                AnimatedBuilder(
                  animation: _messageController,
                  builder: (context, child) {
                    final len = _messageController.text.length;
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Text('${len.toString()} / ${_messageMaxLength.toString()}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.lightTextPrimary,
                            ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                PrimaryButton(
                  label: _isSubmitting ? 'Submitting...' : 'Submit',
                  onPressed: _isSubmitting ? null : _submitFeedback,
                ),
                const SizedBox(height: 12),
                SecondaryButton(
                  label: 'Cancel',
                  onPressed: () {
                    Navigator.of(context).pushNamed('/settings');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final dto = FeedbackDto(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        subject: _subjectController.text.trim(),
        message: _messageController.text.trim(),
      );

      final res = await _feedbackService.submitFeedback(dto);

      if (!mounted) return;

      if (res.success) {
        // Show success snackbar and clear the form after confirmed success.
        showFlexSnackbar(context, title: 'Feedback submitted', type: SnackbarType.success);

        _nameController.clear();
        _emailController.clear();
        _subjectController.clear();
        _messageController.clear();
      } else {
        showFlexSnackbar(context,
            title: res.message ?? 'Submission failed', type: SnackbarType.stop);
      }
    } catch (e) {
      if (mounted) showFlexSnackbar(context, title: 'Error: ${e.toString()}', type: SnackbarType.stop);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
