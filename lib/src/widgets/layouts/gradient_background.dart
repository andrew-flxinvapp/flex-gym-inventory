import 'package:flutter/material.dart';

/// A small convenience widget that provides the project's common radial
/// background gradient. Pass a child to render it on top of the gradient,
/// or override the gradient with the `gradient` parameter.
class GradientBackground extends StatelessWidget {
  final Widget? child;
  final Gradient? gradient;

  const GradientBackground({
    Key? key,
    this.child,
    this.gradient,
  }) : super(key: key);

  static const Gradient defaultGradient = RadialGradient(
    center: Alignment(0.9, -0.62),
    radius: 1.6,
    focal: Alignment(0.9, -0.7),
    focalRadius: 0.001,
    colors: [
      Color(0xFF1F4F66),
      Color(0xFF023246),
      Color(0xFF010D1B),
      Color(0xFF000000),
    ],
    stops: [0.0, 0.3, 0.8, 1.0],
    transform: GradientRotation(0.25),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? defaultGradient,
      ),
      child: child,
    );
  }
}
