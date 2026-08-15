import 'package:flex_gym_inventory/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum PrimaryButtonVariant { light, dark }

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final PrimaryButtonVariant variant;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.width,
    this.height,
    this.variant = PrimaryButtonVariant.light,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = variant == PrimaryButtonVariant.dark;
    final btnWidth = width ?? double.infinity;
    final btnHeight = height ?? 50;

    final backgroundColor = isDark ? AppTheme.lightBackground : AppTheme.darkBackground;
    final foregroundColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final textColor = isDark ? AppTheme.darkBackground : AppTheme.darkTextPrimary;

    return SizedBox(
      width: btnWidth,
      height: btnHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppTheme.lightTextPrimary, width: 1),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
