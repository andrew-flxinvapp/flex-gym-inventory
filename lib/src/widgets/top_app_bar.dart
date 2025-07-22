import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_icons.dart';

/// A reusable, design-centered top app bar for Flex Gym Inventory screens.
/// - Background: AppTheme.lightAppBar
/// - Height: 70px
/// - Title: Uses displayMedium and darkTextPrimary from AppTheme
/// - Optionally displays a platform-adaptive back arrow or a right-aligned text button.

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackArrow;
  final bool showRightIcon;
  final String? rightIcon; // asset path for icon
  final VoidCallback? onRightIconPressed;
  final Widget? rightWidget;

  const TopAppBar({
    super.key,
    required this.title,
    this.showBackArrow = false,
    this.showRightIcon = false,
    this.rightIcon,
    this.onRightIconPressed,
    this.rightWidget,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.lightAppBar,
      elevation: 0,
      centerTitle: false,
      toolbarHeight: 60,
      leading: showBackArrow
          ? IconButton(
              icon: SizedBox(
                width: 32,
                height: 32,
                child: Image.asset(
                  AppIcons.back,
                  color: AppTheme.darkTextPrimary,
                ),
              ),
              onPressed: () => Navigator.of(context).maybePop(),
              tooltip: 'Back',
            )
          : null,
      actions: rightWidget != null
          ? [
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: rightWidget!,
              ),
            ]
          : (showRightIcon && rightIcon != null
              ? [
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: IconButton(
                      icon: SizedBox(
                        width: 24,
                        height: 24,
                        child: Image.asset(
                          rightIcon!,
                          color: AppTheme.darkTextPrimary,
                        ),
                      ),
                      onPressed: onRightIconPressed,
                      tooltip: 'Action',
                    ),
                  ),
                ]
              : null),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showBackArrow) const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppTheme.darkTextPrimary,
                ),
          ),
        ],
      ),
    );
  }
}

/// Usage examples:

/*
appBar: TopAppBar(
  title: 'Your Title',
  showBackArrow: true, // or false
  showRightIcon: true, // or false
  rightIcon: AppIcons.add, // or any icon asset path, or null if not needed
  onRightIconPressed: () {
    // handle right icon action
  }, // or null if not needed
),
*/