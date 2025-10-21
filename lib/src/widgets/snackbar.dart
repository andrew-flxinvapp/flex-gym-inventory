import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_icons.dart';

enum SnackbarType { success, warning, update, stop }

class FlexSnackbar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final SnackbarType type;
  final VoidCallback? onClose;

  const FlexSnackbar({
    super.key,
    required this.title,
    this.subtitle,
    required this.type,
    this.onClose,
  });

  String get _iconAsset {
    switch (type) {
      case SnackbarType.success:
        return AppIcons.success;
      case SnackbarType.warning:
        return AppIcons.warning;
      case SnackbarType.update:
        return AppIcons.update;
      case SnackbarType.stop:
        return AppIcons.stop;
    }
  }

  Color get _iconColor {
    switch (type) {
      case SnackbarType.success:
        return AppTheme.successColor;
      case SnackbarType.warning:
        return AppTheme.warningColor;
      case SnackbarType.update:
        return AppTheme.updateColor;
      case SnackbarType.stop:
        return AppTheme.stopColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 386,
      height: 58,
      decoration: BoxDecoration(
        color: AppTheme.lightCard,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          // Icon
          SizedBox(
            width: 32,
            height: 32,
            child: Image.asset(
              _iconAsset,
              color: _iconColor,
            ),
          ),
          const SizedBox(width: 16),
          // Texts
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.lightTextPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: AppTheme.lightTextPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          // Close icon
          IconButton(
            icon: const Icon(Icons.close, color: AppTheme.lightTextPrimary),
            onPressed: onClose,
            tooltip: 'Close',
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
