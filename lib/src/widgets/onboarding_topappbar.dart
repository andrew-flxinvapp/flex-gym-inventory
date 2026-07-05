import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_icons.dart';

/// OnboardingLogoAppBar: a single configurable appbar for onboarding/auth screens.
/// Use `theme` to pick the light or dark variant per screen.
enum OnboardingAppBarTheme { light, dark }

class OnboardingLogoAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final bool showBackArrow;
  final VoidCallback? onBackArrowPressed;
  final double topSpacing;
  final double bottomSpacing;
  final double logoHeight;
  final double logoWidth;
  final OnboardingAppBarTheme theme;

  const OnboardingLogoAppBar({
    super.key,
    this.topSpacing = 70,
    this.bottomSpacing = 10,
    this.logoHeight = 50.9,
    this.logoWidth = 200,
    this.showBackArrow = false,
    this.onBackArrowPressed,
    this.theme = OnboardingAppBarTheme.light,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(topSpacing + logoHeight + bottomSpacing);

  @override
  Widget build(BuildContext context) {
    final isDark = theme == OnboardingAppBarTheme.dark;
    final background = isDark ? AppTheme.transparent : AppTheme.lightBackground;
    final iconColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final logoAsset = isDark
        ? 'lib/assets/images/fgi_logo_white.svg'
        : 'lib/assets/images/fgi_logo_navy.svg';

    return Container(
      color: background,
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
                      color: iconColor,
                    ),
                    onPressed: onBackArrowPressed ?? () => Navigator.of(context).maybePop(),
                  )
                else
                  const SizedBox(width: 48), // Space for alignment
                Expanded(
                  child: Center(
                    child: SizedBox(
                      height: logoHeight,
                      width: logoWidth,
                      child: SvgPicture.asset(
                        logoAsset,
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
