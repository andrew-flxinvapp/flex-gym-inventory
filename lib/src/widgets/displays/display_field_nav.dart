import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import 'package:flex_gym_inventory/theme/app_icons.dart';

class DisplayFieldNav extends StatelessWidget {
  final VoidCallback? onPressed;
  final String title;
  final String iconPath;

  const DisplayFieldNav({
    super.key,
    this.onPressed,
    this.title = 'Wishlist',
    this.iconPath = AppIcons.sparkle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Material(
        color: AppTheme.lightCard,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Image.asset(
                  iconPath,
                  width: 22,
                  height: 22,
                  color: AppTheme.lightTextPrimary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.lightTextPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Image.asset(
                  AppIcons.forward,
                  width: 24,
                  height: 24,
                  color: AppTheme.lightTextPrimary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
