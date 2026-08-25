import 'package:flutter/material.dart';
import '../widgets/snackbar.dart';

import '../../enum/app_enums.dart';
import '../../service/support_service.dart';
import '../data/dtos/support_request_dto.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/inputs/dropdown_field.dart';
import '../widgets/inputs/text_input_field.dart';
import '../widgets/inputs/multiline_text_input.dart';
import '../widgets/cards/info_card.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/buttons/secondary_button.dart';
import '../../theme/app_theme.dart';


class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  SupportCategory? _selectedCategory;
  bool _isSubmitting = false;

  final SupportService _supportService = SupportService();

  static const int _messageMaxLength = 2000;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_enforceMessageMaxLength);
  }

  @override
  void dispose() {
    _messageController.removeListener(_enforceMessageMaxLength);
    _subjectController.dispose();
    _nameController.dispose();
    _emailController.dispose();
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
      appBar: const TopAppBar(
        title: 'Support',
        showBackArrow: true,
        showRightIcon: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Need Help?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTextPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "Have a question, found a bug, or need assistance? Send us a support request and we'll typically respond within 48 hours.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTextPrimary,
                  ),
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
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
                      final emailRegex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
                      if (!emailRegex.hasMatch(email)) return 'Invalid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomDropdownField<SupportCategory>(
                    hintText: 'Category',
                    showAsterisk: true,
                    items: SupportCategory.values,
                    value: _selectedCategory,
                    getLabel: (c) => c.label,
                    onChanged: (v) => setState(() => _selectedCategory = v),
                    validator: (v) => v == null ? 'Required' : null,
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
                    maxLines: 6,
                    height: 200,
                    validator: (s) => s == null || s.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 4),
                  AnimatedBuilder(
                    animation: _messageController,
                    builder: (context, child) {
                      final len = _messageController.text.length;
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Text('${len.toString()} / 2000',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.lightTextPrimary,
                              ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  InfoCard(
                    title: 'Diagnostic information included',
                    subtitle:
                        'We include your app version, device, and OS details to help diagnose issues.',
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: _isSubmitting ? 'Submitting...' : 'Submit Support Request',
                    onPressed: _isSubmitting ? null : _submitSupportRequest,
                  ),
                  const SizedBox(height: 16),
                  SecondaryButton(
                    label: 'Cancel',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitSupportRequest() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) return;
    setState(() => _isSubmitting = true);

    try {
      final dto = SupportRequestDto(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        category: _selectedCategory!,
        subject: _subjectController.text.trim(),
        message: _messageController.text.trim(),
      );

      final res = await _supportService.submitSupportRequest(dto);

      if (res.success) {
        // Clear fields after confirmed success, then show success UI.
        _nameController.clear();
        _emailController.clear();
        _subjectController.clear();
        _messageController.clear();
        setState(() => _selectedCategory = null);

        showFlexSnackbar(context, title: 'Support request submitted', type: SnackbarType.success);
        Navigator.of(context).pop();
      } else {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Submission failed'),
            content: SingleChildScrollView(child: Text(res.message ?? 'An error occurred')),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK')),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
