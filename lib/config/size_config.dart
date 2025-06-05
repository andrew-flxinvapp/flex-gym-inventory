// Utility class for responsive sizing based on device screen dimensions.
// Call SizeConfig.init(context) in the top-level widget (e.g., in build method of main screen)
// and use SizeConfig.blockWidth, blockHeight, or getProportionateScreenWidth/Height for scaling.

import 'package:flutter/widgets.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockWidth;
  static late double blockHeight;
  static late double textScaleFactor;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockWidth = screenWidth / 100;
    blockHeight = screenHeight / 100;
    textScaleFactor = _mediaQueryData.textScaleFactor;
  }

  /// Returns a width value proportional to the screen width
  static double getProportionateScreenWidth(double inputWidth) {
    return (inputWidth / 375.0) * screenWidth;
  }

  /// Returns a height value proportional to the screen height
  static double getProportionateScreenHeight(double inputHeight) {
    return (inputHeight / 812.0) * screenHeight;
  }
}
