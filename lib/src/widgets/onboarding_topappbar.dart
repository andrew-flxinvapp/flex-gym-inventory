import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../theme/app_theme.dart';

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
