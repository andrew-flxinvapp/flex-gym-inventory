import 'package:flex_gym_inventory/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'floating_bottom_nav.dart';

/// A reusable scaffold that places a floating nav bar at the bottom of the screen.
/// Usage:
/// ```dart
/// FloatingNavScaffold(
///   body: YourScreenContent(),
/// )
/// ```
class FloatingNavScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Color? backgroundColor;
  final bool useSafeArea;

  const FloatingNavScaffold({
    Key? key,
    required this.body,
    this.appBar,
    this.backgroundColor,
    this.useSafeArea = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget content = body;
    if (useSafeArea) {
      content = SafeArea(child: content);
    }
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      body: Stack(
        children: [
          content,
          // Gradient overlay to fade out content under the nav bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 115, // Match Figma spec
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    stops: [0, 0.6, 1], // 0-72px solid, then fade
                    colors: [
                      Color(0xFFF4F4F5), // solid for 72px
                      Color(0xFFF4F4F5), // start fade
                      Color(0x00F4F4F5), // fully transparent at top
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: FloatingBottomNav(),
            ),
          ),
        ],
      ),
    );
  }
}
