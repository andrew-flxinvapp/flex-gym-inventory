import 'package:flutter/material.dart';
import '../cards/base_card.dart';
import '../../../theme/app_theme.dart';

class ImagePlaceholderLarge extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget? child;

  const ImagePlaceholderLarge({
    super.key,
    this.width,
    this.height,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      width: width,
      body: Container(
        height: height ?? 210,
        decoration: BoxDecoration(
          color: AppTheme.lightBackground,
          border: Border.all(color: AppTheme.dividers),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: child ?? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_outlined,
              size: 48,
              color: AppTheme.lightTextPrimary,
            ),
            const SizedBox(height: 8),
            Text(
              'No image',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTextSecondary,
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}
