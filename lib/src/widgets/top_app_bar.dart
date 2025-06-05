import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../theme/app_theme.dart';

/// A reusable, design-centered top app bar for Flex Gym Inventory screens.
/// - Background: AppTheme.lightAppBar
/// - Height: 70px
/// - Title: Uses displayMedium and darkTextPrimary from AppTheme
/// - Optionally displays a platform-adaptive back arrow or a right-aligned text button.

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackArrow;
  final VoidCallback? onBack;
  final String? rightButtonText;
  final VoidCallback? onRightButtonPressed;

  const TopAppBar({
    super.key,
    required this.title,
    this.showBackArrow = false,
    this.onBack,
    this.rightButtonText,
    this.onRightButtonPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return AppBar(
      backgroundColor: AppTheme.lightAppBar,
      elevation: 0,
      centerTitle: true,
      toolbarHeight: 70,
      leading: showBackArrow
          ? IconButton(
              icon: Icon(
                isIOS ? CupertinoIcons.arrow_left : Icons.arrow_back,
                color: AppTheme.darkTextPrimary,
              ),
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              tooltip: 'Back',
            )
          : null,
      actions: rightButtonText != null
          ? [
              TextButton(
                onPressed: onRightButtonPressed,
                child: Text(
                  rightButtonText!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.darkTextPrimary,
                        fontWeight: FontWeight.normal,
                      ),
                ),
              ),
            ]
          : null,
      title: Text(
        title,
        style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: AppTheme.darkTextPrimary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

/// Usage examples:

/* Useage title only
appBar: const TopAppBar(
  title: 'Dashboard'
  ),
*/ 

/* Useage with back button
TopAppBar(
  title: 'Details',
  showBackArrow: true,
  onBack: () => Navigator.of(context).pop(),
  ),
*/ 

/* Usage with right button text
TopAppBar(
  title: 'Details',
  rightButtonText: 'Edit',
  onRightButtonPressed: () { /* handle edit */},
  ),
*/

/* Usage with both back button and right button text
 TopAppBar(
  title: 'Edit Gym',
  showBackArrow: true,
  rightButtonText: 'Save',
  onRightButtonPressed: () { /* handle save */ },
  ),
*/