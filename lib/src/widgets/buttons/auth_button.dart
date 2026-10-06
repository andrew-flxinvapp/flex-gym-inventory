import 'package:flex_gym_inventory/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum SmallAuthButtonVariant { filled, outlined }

/// A compact auth action button used side-by-side on the auth landing screen.
class SmallAuthButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final SmallAuthButtonVariant variant;

  const SmallAuthButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = SmallAuthButtonVariant.filled,
  });

  @override
  Widget build(BuildContext context) {
    final isFilled = variant == SmallAuthButtonVariant.filled;

    // Shared dimensions and shape
    const double btnHeight = 50;
    const borderRadius = BorderRadius.all(Radius.circular(16));
    const EdgeInsetsGeometry innerPadding = EdgeInsets.symmetric(horizontal: 16);

    final textStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
        );

    if (isFilled) {
      // Filled: off white background, blue-black text
      return SizedBox(
        height: btnHeight,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.lightBackground,
            foregroundColor: AppTheme.darkBackground,
            padding: innerPadding,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius,
            ),
            elevation: 0,
            minimumSize: const Size(0, btnHeight),
          ),
          child: Text(
            label,
            style: textStyle?.copyWith(color: AppTheme.darkBackground),
          ),
        ),
      );
    }

    // Outlined: transparent background, off white border and text
    return SizedBox(
      height: btnHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppTheme.transparent,
          foregroundColor: AppTheme.lightBackground,
          side: const BorderSide(color: AppTheme.lightBackground, width: 1),
          padding: innerPadding,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
          ),
          minimumSize: const Size(0, btnHeight),
        ),
        child: Text(
          label,
          style: textStyle?.copyWith(color: AppTheme.lightBackground),
        ),
      ),
    );
  }
}
