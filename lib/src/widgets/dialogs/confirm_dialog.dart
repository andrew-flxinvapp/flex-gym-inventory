import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool usePrimaryColor;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    required this.confirmText,
    this.cancelText = 'Cancel',
    required this.onConfirm,
    this.onCancel,
    this.usePrimaryColor = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      backgroundColor: AppTheme.lightCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        style: Theme.of(context).textTheme.displaySmall?.copyWith(
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
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onCancel != null) onCancel!();
              },
              child: Text(
                cancelText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTextPrimary,
                    ),
              ),
            ),
            const SizedBox(width: 56),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: usePrimaryColor
                    ? AppTheme.lightTextPrimary
                    : AppTheme.stopColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        ),
      ],
    );
  }
}
