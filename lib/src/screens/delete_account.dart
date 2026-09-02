import 'package:flex_gym_inventory/routes/routes.dart';
import 'package:flex_gym_inventory/service/delete_account_service.dart';
import 'package:flex_gym_inventory/src/data/dtos/delete_account_dto.dart';
import 'package:flex_gym_inventory/src/widgets/dialogs/confirm_dialog.dart';
import 'package:flex_gym_inventory/src/widgets/snackbar.dart';
import 'package:flex_gym_inventory/utilities/logging_handler.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/selectors/delete_account_selector.dart';
import '../widgets/inputs/multiline_text_input.dart';
import '../widgets/buttons/warning_button.dart';
import '../widgets/buttons/secondary_button.dart';
import 'package:flex_gym_inventory/theme/app_theme.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final TextEditingController _reasonController = TextEditingController();
  final DeleteAccountService _deleteAccountService = DeleteAccountService();
  DeleteAccountReason? _selectedReason;
  bool _isLoading = false;
  static const int _reasonMaxLength = 2000;

  bool get _showOtherDetails => _selectedReason == DeleteAccountReason.other;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _onReasonSelected(DeleteAccountReason reason) {
    setState(() {
      if (_selectedReason == reason) {
        _selectedReason = null;
      } else {
        _selectedReason = reason;
      }
      if (_selectedReason != DeleteAccountReason.other) {
        _reasonController.clear();
      }
    });
  }

  Future<void> _confirmDeleteAccount() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final dto = DeleteAccountDto(
        reason: _selectedReason,
        details:
            _selectedReason == DeleteAccountReason.other
                ? _reasonController.text
                : null,
      );

      final result = await _deleteAccountService.deleteAccount(dto);
      if (!mounted) return;

      if (!result.success) {
        showFlexSnackbar(
          context,
          title: result.message ?? 'Unable to delete your account right now.',
          type: SnackbarType.stop,
        );
        return;
      }

      try {
        await _deleteAccountService.clearLocalDataForCurrentUser();
      } catch (e, st) {
        LogHandler.warning(
          'DeleteAccountScreen',
          'Local cleanup failed after remote deletion: $e',
          e,
          st,
        );
      }

      try {
        await Supabase.instance.client.auth.signOut();
      } catch (e, st) {
        LogHandler.warning(
          'DeleteAccountScreen',
          'Sign out after account deletion failed: $e',
          e,
          st,
        );
      }

      if (!mounted) return;

      await Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.startupRouter,
        (route) => false,
      );
    } catch (e, st) {
      LogHandler.error(
        'DeleteAccountScreen',
        'Delete account request failed: $e',
        e,
        st,
      );
      if (mounted) {
        showFlexSnackbar(
          context,
          title: 'Unable to delete your account right now.',
          type: SnackbarType.stop,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _askForFinalConfirmation() async {
    if (_isLoading) return;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return ConfirmDialog(
          title: 'Delete account?',
          content:
              'This will permanently delete your account and all of your saved gym, equipment, wishlist, and preference data. This action cannot be undone.',
          confirmText: 'Delete',
          cancelText: 'Cancel',
          onConfirm: _confirmDeleteAccount,
          usePrimaryColor: false,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: TopAppBar(
          title: 'Delete Account',
          showBackArrow: true,
          showRightIcon: false,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Deleting your account will permanently remove all of your data. This action cannot be undone.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Would you mind telling us why you\'re leaving?',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.lightTextPrimary,
                      ),
                    ),
                    DeleteAccountSelector(
                      selected: _selectedReason == DeleteAccountReason.notUsingApp,
                      text: 'I don\'t use the app anymore',
                      onTap: () => _onReasonSelected(DeleteAccountReason.notUsingApp),
                    ),
                    DeleteAccountSelector(
                      selected: _selectedReason == DeleteAccountReason.missingFeatures,
                      text: 'The app is missing features I need',
                      onTap: () => _onReasonSelected(DeleteAccountReason.missingFeatures),
                    ),
                    DeleteAccountSelector(
                      selected: _selectedReason == DeleteAccountReason.technicalIssues,
                      text: 'I\'m having technical issues',
                      onTap: () => _onReasonSelected(DeleteAccountReason.technicalIssues),
                    ),
                    DeleteAccountSelector(
                      selected: _selectedReason == DeleteAccountReason.difficultToUse,
                      text: 'The app is too difficult to use',
                      onTap: () => _onReasonSelected(DeleteAccountReason.difficultToUse),
                    ),
                    DeleteAccountSelector(
                      selected: _selectedReason == DeleteAccountReason.notEnoughValue,
                      text: 'I\'m not getting enough value from the app',
                      onTap: () => _onReasonSelected(DeleteAccountReason.notEnoughValue),
                    ),
                    DeleteAccountSelector(
                      selected: _selectedReason == DeleteAccountReason.privacyConcerns,
                      text: 'I have privacy or data concerns',
                      onTap: () => _onReasonSelected(DeleteAccountReason.privacyConcerns),
                    ),
                    DeleteAccountSelector(
                      selected: _selectedReason == DeleteAccountReason.switchingApps,
                      text: 'I\'m switching to another app',
                      onTap: () => _onReasonSelected(DeleteAccountReason.switchingApps),
                    ),
                    DeleteAccountSelector(
                      selected: _selectedReason == DeleteAccountReason.other,
                      text: 'Other',
                      onTap: () => _onReasonSelected(DeleteAccountReason.other),
                    ),
                    if (_showOtherDetails) ...[
                      const SizedBox(height: 16),
                      CustomMultilineTextInput(
                        hintText: 'Tell us more (optional)',
                        controller: _reasonController,
                        maxLength: _reasonMaxLength,
                      ),
                      const SizedBox(height: 4),
                      AnimatedBuilder(
                        animation: _reasonController,
                        builder: (context, child) {
                          final len = _reasonController.text.length;
                          return Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '$len / $_reasonMaxLength',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.lightTextPrimary,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 24),
                    WarningButton(
                      label: 'Delete Account',
                      onPressed: _isLoading ? () {} : _askForFinalConfirmation,
                    ),
                    const SizedBox(height: 16),
                    SecondaryButton(
                      label: 'Cancel',
                      onPressed: _isLoading ? () {} : () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
