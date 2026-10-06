import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../config/size_config.dart';
import 'gradient_background.dart';

/// A small convenience screen wrapper used by app screens.
///
/// Responsibilities:
/// - Calls `SizeConfig.init(context)` so children can use responsive helpers.
/// - Optionally wraps content in a `SafeArea`.
/// - Provides a scaffold with a configurable `backgroundColor`.
/// - When `useGradient` is true, paints the `GradientBackground` behind
///   the scaffold body and makes the scaffold background transparent.
/// - When `lightSystemUi` is non-null, sets the system status bar and
///   navigation/home indicator style: `true` for light (white) icons on dark
///   screens, `false` for dark icons on light screens. Null leaves it unchanged.
class AppScreen extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final bool useGradient;
  final Gradient? gradient;
  final bool unfocusOnTap;
  final bool safeArea;
  final bool? lightSystemUi;

  const AppScreen({
    Key? key,
    required this.child,
    this.backgroundColor,
    this.useGradient = false,
    this.gradient,
    this.safeArea = true,
    this.unfocusOnTap = false,
    this.lightSystemUi,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize size helpers for downstream widgets.
    SizeConfig.init(context);

    Widget content = safeArea ? SafeArea(child: child) : child;

    Widget result;

    if (useGradient) {
      // GradientBackground already expands to fill its parent when used as
      // the top-level child inside a Scaffold body.
      result = GradientBackground(gradient: gradient, child: content);
    } else {
      final bg = backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;
      result = Container(
        constraints: const BoxConstraints.expand(),
        color: bg,
        child: content,
      );
    }

    if (unfocusOnTap) {
      result = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: result,
      );
    }

    final light = lightSystemUi;
    if (light != null) {
      final iconBrightness = light ? Brightness.light : Brightness.dark;
      result = AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          // iOS status bar: statusBarBrightness describes the background.
          statusBarBrightness: light ? Brightness.dark : Brightness.light,
          statusBarIconBrightness: iconBrightness,
          systemNavigationBarIconBrightness: iconBrightness,
        ),
        child: result,
      );
    }

    return result;
  }
}
