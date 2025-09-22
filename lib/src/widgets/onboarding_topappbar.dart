import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_icons.dart';

/// OnboardingLogoAppBar: For onboarding/auth screens with centered logo only
class OnboardingLogoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackArrow;
  final VoidCallback? onBackArrowPressed;
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
    this.showBackArrow = false,
    this.onBackArrowPressed,
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (showBackArrow)
                  IconButton(
                    icon: Image.asset(
                      AppIcons.back,
                      height: 32,
                      width: 32,
                      color: AppTheme.lightTextPrimary,
                    ),
                    onPressed: onBackArrowPressed ?? () {
                      Navigator.of(context).maybePop();
                    },
                  )
                else
                  const SizedBox(width: 48), // Space for alignment
                Expanded(
                  child: Center(
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
                ),
                const SizedBox(width: 48), // Right side spacing
              ],
            ),
            SizedBox(height: bottomSpacing),
          ],
        ),
      ),
    );
  }
}
