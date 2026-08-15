import 'package:flutter/material.dart';

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
class AppScreen extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final bool useGradient;
  final Gradient? gradient;
  final bool safeArea;

  const AppScreen({
    Key? key,
    required this.child,
    this.backgroundColor,
    this.useGradient = false,
    this.gradient,
    this.safeArea = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize size helpers for downstream widgets.
    SizeConfig.init(context);

    Widget content = safeArea ? SafeArea(child: child) : child;

    if (useGradient) {
      // GradientBackground already expands to fill its parent when used as
      // the top-level child inside a Scaffold body.
      return GradientBackground(gradient: gradient, child: content);
    }

    final bg = backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;
    return Container(
      constraints: const BoxConstraints.expand(),
      color: bg,
      child: content,
    );
  }
}
