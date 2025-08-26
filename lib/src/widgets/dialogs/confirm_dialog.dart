import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    required this.confirmText,
    this.cancelText = 'Cancel',
    required this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.lightCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.lightTextPrimary,
            ),
      ),
      content: Text(
        content,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTextPrimary,
            ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (onCancel != null) onCancel!();
          },
          child: Text(
            cancelText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTextSecondary,
                ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.stopColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: Text(
            confirmText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
      ],
    );
  }
}
