import 'dart:io';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../theme/app_theme.dart';
import '../../enum/app_enums.dart';
import '../../service/support_service.dart';
import '../data/dtos/support_request_dto.dart';
import '../../routes/routes.dart';
import '../widgets/inputs/dropdown_field.dart';
import '../widgets/inputs/image_input.dart';
import '../widgets/cards/info_card.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/inputs/text_input_field.dart';
import '../widgets/inputs/multiline_text_input.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/buttons/secondary_button.dart';
import '../widgets/snackbar.dart';
import 'package:flutter/services.dart';
import '../../utilities/logging_handler.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _messageController;
  late final TextEditingController _subjectController;
  SupportCategory? _selectedCategory;
  File? _screenshotFile;
  bool _isSubmitting = false;
  int _charCount = 0;
  final SupportService _supportService = SupportService();

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _subjectController = TextEditingController();
    _messageController.addListener(() {
      setState(() {
        _charCount = _messageController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: const TopAppBar(
        title: 'Support',
        showBackArrow: true,
        showRightIcon: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need help?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Have a question, found a bug, or need assistance? Send us a support request and we will typically respond within 48 hours.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.normal,
                      color: AppTheme.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomDropdownField<SupportCategory>(
                    hintText: 'Category',
                    items: SupportCategory.values,
                    value: _selectedCategory,
                    showAsterisk: true,
                    getLabel: (item) => item.label,
                    validator: (val) => val == null ? 'Required' : null,
                    onChanged:
                        (value) => setState(() => _selectedCategory = value),
                  ),
                  const SizedBox(height: 16),
                  CustomTextInputField(
                    hintText: 'Subject',
                    showAsterisk: true,
                    controller: _subjectController,
                    validator:
                        (s) =>
                            s == null || s.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Screenshot (Optional)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a screenshot to help us better understand the issue.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.normal,
                      color: AppTheme.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ImageInput(
                    onImageChanged:
                        (file) => setState(() => _screenshotFile = file),
                  ),
                  const SizedBox(height: 16),
                  CustomMultilineTextInput(
                    hintText: 'Describe your issue or question in detail...',
                    showAsterisk: true,
                    controller: _messageController,
                    maxLines: 45,
                    validator: (s) {
                      if (s == null || s.trim().isEmpty) return 'Required';
                      if (s.length > 2000)
                        return 'Message must be 2000 characters or less';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$_charCount/2000',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTextPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InfoCard(
                    title: 'Diagnostic information included',
                    subtitle:
                        'We include your app version, device, and OS details to help diagnose issues.',
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    label:
                        _isSubmitting
                            ? 'Submitting...'
                            : 'Submit Support Request',
                    onPressed:
                        _isSubmitting
                            ? null
                            : () async {
                              if (!_formKey.currentState!.validate()) return;

                              // require authenticated user
                              final user =
                                  Supabase.instance.client.auth.currentUser;
                              if (user == null) {
                                showFlexSnackbar(
                                  context,
                                  title: 'Sign in required',
                                  subtitle:
                                      'Please sign in to submit a support request.',
                                  type: SnackbarType.update,
                                );
                                Navigator.of(
                                  context,
                                ).pushNamed(AppRoutes.login);
                                return;
                              }

                              if (_selectedCategory == null) return;

                              setState(() => _isSubmitting = true);

                              final dto = SupportRequestDto(
                                category: _selectedCategory!,
                                subject: _subjectController.text,
                                message: _messageController.text,
                              );

                              final res = await _supportService
                                  .submitSupportRequest(
                                    dto,
                                    screenshot: _screenshotFile,
                                  );

                              setState(() => _isSubmitting = false);

                              if (res.success) {
                                showFlexSnackbar(
                                  context,
                                  title: 'Support request sent',
                                  subtitle: 'We will respond within 48 hours.',
                                  type: SnackbarType.success,
                                );
                                Navigator.of(context).pop();
                              } else {
                                // Log full error and show snackbar + dialog with full details for copying.
                                LogHandler.error('SupportScreen', 'Support submission failed', res.message);
                                showFlexSnackbar(
                                  context,
                                  title: 'Submission failed',
                                  subtitle: res.message ?? 'An error occurred.',
                                  type: SnackbarType.stop,
                                );
                                // Show full error in dialog so it's readable and copyable.
                                await showDialog<void>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Submission error'),
                                    content: SingleChildScrollView(
                                      child: Text(res.message ?? 'An unknown error occurred.'),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(text: res.message ?? ''));
                                          Navigator.of(ctx).pop();
                                        },
                                        child: const Text('Copy'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
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
      ),
    );
  }
}
