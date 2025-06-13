import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
    return AppBar(
      backgroundColor: AppTheme.lightAppBar,
      elevation: 0,
      centerTitle: true,
      toolbarHeight: 70,
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
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              tooltip: 'Back',
            )
          : null,
      actions: rightButtonText == 'Edit'
          ? [
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: IconButton(
                  icon: SizedBox(
                    width: 24,
                    height: 24,
                    child: Image.asset(
                      AppIcons.edit,
                      color: AppTheme.darkTextPrimary,
                    ),
                  ),
                  onPressed: onRightButtonPressed,
                  tooltip: 'Edit',
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

/// OnboardingLogoAppBar: For onboarding/auth screens with centered logo only
class OnboardingLogoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double topSpacing;
  final double bottomSpacing;
  final double logoHeight;
  final double logoWidth;

  const OnboardingLogoAppBar({
    super.key,
    this.topSpacing = 70,
    this.bottomSpacing = 10,
    this.logoHeight = 50.9,
    this.logoWidth = 200,
  });

  @override
  Size get preferredSize => Size.fromHeight(topSpacing + logoHeight + bottomSpacing);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.lightBackground,
      child: SizedBox(
        height: topSpacing + logoHeight + bottomSpacing,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: topSpacing),
            Center(
              child: SizedBox(
                height: logoHeight,
                width: logoWidth,
                child: SvgPicture.asset(
                  'lib/assets/images/fgi_logo.svg',
                  package: null,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: bottomSpacing),
          ],
        ),
      ),
    );
  }
}

/// Usage examples:

/* Title only
appBar: const TopAppBar(
  title: 'Dashboard',
),
*/

/* With back button
appBar: TopAppBar(
  title: 'Details',
  showBackArrow: true,
  onBack: () => Navigator.of(context).pop(),
),
*/

/* With right icon button (Edit)
appBar: TopAppBar(
  title: 'Details',
  rightButtonText: 'Edit',
  onRightButtonPressed: () { /* handle edit */ },
),
*/

/* With back button and right text button (Save)
appBar: TopAppBar(
  title: 'Edit Gym',
  showBackArrow: true,
  rightButtonText: 'Save',
  onRightButtonPressed: () { /* handle save */ },
),
*/