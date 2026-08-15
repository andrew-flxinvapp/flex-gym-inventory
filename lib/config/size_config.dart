// Utility class for responsive sizing based on device screen dimensions.
// Call SizeConfig.init(context) in the top-level widget (e.g., in build method of main screen)
// and use SizeConfig.blockWidth, blockHeight, or getProportionateScreenWidth/Height for scaling.

import 'package:flutter/widgets.dart';

/// Utility helpers for responsive sizing.
///
/// Usage: call `SizeConfig.init(context)` once (for example in the
/// top-level widget's `build`) and then use the helpers below.
class SizeConfig {
  static late MediaQueryData _mediaQueryData;

  /// Full screen width (including system padding)
  static late double screenWidth;

  /// Full screen height (including system padding)
  static late double screenHeight;

  /// Width available inside safe areas (excludes left/right padding)
  static late double safeWidth;

  /// Height available inside safe areas (excludes top/bottom padding)
  static late double safeHeight;

  /// 1% of the available width
  static late double blockSizeHorizontal;

  /// 1% of the available height
  static late double blockSizeVertical;

  /// Device text scale factor
  static late double textScaleFactor;

  /// Initialize the config with values from the given [context].
  ///
  /// This should be called early (for example in the top-level widget's
  /// `build` method). It reads `MediaQuery` and computes safe-area aware
  /// sizing helpers.
  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    _mediaQueryData = mediaQuery;

    screenWidth = mediaQuery.size.width;
    screenHeight = mediaQuery.size.height;

    final padding = mediaQuery.padding;
    safeWidth = screenWidth - padding.left - padding.right;
    safeHeight = screenHeight - padding.top - padding.bottom;

    blockSizeHorizontal = safeWidth / 100;
    blockSizeVertical = safeHeight / 100;

    textScaleFactor = mediaQuery.textScaleFactor;
  }

  /// Returns a width value proportional to the safe width.
  ///
  /// [baseWidth] is the design/reference width used in your mockups
  /// (defaults to 402 which is a common mobile reference). Adjust if needed.
  static double getProportionateScreenWidth(double inputWidth,
      {double baseWidth = 402.0}) {
    return (inputWidth / baseWidth) * safeWidth;
  }

  /// Returns a height value proportional to the safe height.
  ///
  /// [baseHeight] is the design/reference height used in your mockups
  /// (defaults to 874 which is a common mobile reference). Adjust if needed.
  static double getProportionateScreenHeight(double inputHeight,
      {double baseHeight = 874.0}) {
    return (inputHeight / baseHeight) * safeHeight;
  }

  /// Convenience getters for percentage-based sizes.
  static double percentWidth(double percent) => blockSizeHorizontal * percent;
  static double percentHeight(double percent) => blockSizeVertical * percent;

  /// Whether the device is in portrait orientation.
  static bool get isPortrait => screenHeight >= screenWidth;
}
