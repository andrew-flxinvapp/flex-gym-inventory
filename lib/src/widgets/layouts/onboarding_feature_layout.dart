import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

/// Shared body for the onboarding feature screens: heading, description and a
/// device mockup that runs down behind the action button and fades into the
/// dark background at the level of the button.
class OnboardingFeatureLayout extends StatelessWidget {
  final String title;
  final String description;
  final String mockupAsset;
  final Widget action;

  const OnboardingFeatureLayout({
    super.key,
    required this.title,
    required this.description,
    required this.mockupAsset,
    required this.action,
  });

  static const double _mockupWidth = 350;
  static const double _fadeHeight = 150;
  static const Color _fadeColor = Color(0xFF00060E);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: textTheme.displayMedium?.copyWith(
                              color: AppTheme.darkTextPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            description,
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppTheme.darkTextPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Image.asset(
                          mockupAsset,
                          width: _mockupWidth,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ),
                // Anchored to the bottom of the visible area so it reaches full
                // opacity where the button begins.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: _fadeHeight,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [_fadeColor.withValues(alpha: 0), _fadeColor],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: action,
          ),
        ],
      ),
    );
  }
}
