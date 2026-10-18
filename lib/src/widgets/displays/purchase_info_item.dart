import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class PurchaseInfoItem extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final TextStyle? style;
  final TextAlign textAlign;

  const PurchaseInfoItem({
    super.key,
    required this.label,
    this.onTap,
    this.style,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    final itemStyle =
        style ??
        Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: AppTheme.darkTextPrimary) ??
        const TextStyle(fontSize: 12, color: AppTheme.darkTextPrimary);
    final textStyle =
        onTap == null
            ? itemStyle
            : itemStyle.copyWith(decoration: TextDecoration.underline);

    if (onTap == null) {
      return Text(label, style: textStyle, textAlign: textAlign);
    }

    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: itemStyle.color,
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        tapTargetSize: MaterialTapTargetSize.padded,
        textStyle: textStyle,
      ),
      child: Text(label, style: textStyle, textAlign: textAlign),
    );
  }
}
