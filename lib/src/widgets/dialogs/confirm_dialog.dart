import 'dart:async';

import 'package:flutter/material.dart';
import '../../models/ui_message.dart';
import '../../../theme/app_theme.dart';
import '../snackbar.dart';

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
        style: Theme.of(
          context,
        ).textTheme.displaySmall?.copyWith(color: AppTheme.lightTextPrimary),
      ),
      content: Text(
        content,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppTheme.lightTextPrimary),
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
                backgroundColor:
                    usePrimaryColor
                        ? AppTheme.lightTextPrimary
                        : AppTheme.stopColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: Text(
                confirmText,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

void showDeleteConfirmation<T>({
  required BuildContext context,
  required String title,
  required String content,
  required Future<T?> Function() delete,
  VoidCallback? onDeleted,
}) {
  showDialog<void>(
    context: context,
    builder:
        (_) => ConfirmDialog(
          title: title,
          content: content,
          confirmText: 'Delete',
          cancelText: 'Cancel',
          onConfirm: () {
            unawaited(_deleteAndReport(context, delete, onDeleted));
          },
        ),
  );
}

Future<void> _deleteAndReport<T>(
  BuildContext context,
  Future<T?> Function() delete,
  VoidCallback? onDeleted,
) async {
  try {
    final deleted = await delete();
    if (!context.mounted) return;
    if (deleted == null) {
      showFlexSnackbarFromUiMessage(
        context,
        UiMessage(
          'Delete failed',
          subtitle: 'The item could not be deleted.',
          type: UiMessageType.error,
        ),
      );
      return;
    }
    onDeleted?.call();
  } catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'Flex Gym Inventory',
        context: ErrorDescription('while deleting an item'),
      ),
    );
    if (!context.mounted) return;
    showFlexSnackbarFromUiMessage(
      context,
      UiMessage(
        'Delete failed',
        subtitle: error.toString(),
        type: UiMessageType.error,
      ),
    );
  }
}
