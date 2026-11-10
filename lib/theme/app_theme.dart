import 'package:flutter/material.dart';

class AppTheme {
  static const _fontFamily = 'Roboto';

  // Color constants
  static const Color lightPrimary = Color(0xFF287094);
  static const Color lightSecondary = Color(0xFF94B0BE);
  static const Color lightBackground = Color(0xFFF4F4F5);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF023246);
  static const Color lightTextSecondary = Color(0xFF94B0BE);
  static const Color lightAppBar = Color(0xFF010D1B);
  static const Color lightBottomNavBar = Color(0xFFFFFFFF);
  static const Color dividers = Color(0xFFC4C4C9);

  static const Color darkPrimary = Color(0xFF287094);
  static const Color darkSecondary = Color(0xFF94B0BE);
  static const Color darkBackground = Color(0xFF010D1B);
  static const Color darkCard = Color(0xFF1F4F66);
  static const Color darkTextPrimary = Color(0xFFF4F4F5);
  static const Color darkTextSecondary = Color(0xFFF4F4F5);
  static const Color darkAppBar = Color(0xFF023246);
  static const Color darkBottomNavBar = Color(0xFF010D1B);
  static const Color darkDividers = Color(0xFF1F4F66);

  static const Color transparent = Color(0x00000000);

  // Warning and Disabled colors
  static const Color stopColor = Color(0xFFFF3B30);
  static const Color successColor = Color(0xFF34C759);
  static const Color disabledColor = Color(0xFFB9C3C7);
  static const Color warningColor = Color(0xFFFFCC00);
  static const Color updateColor = Color(0xFF4BB4E9);
  static const Color proColor = Color(0xFFC7A109);

  // Apple System Colors
  // Light appearance
  static const red = Color(0xFFFF383C);
  static const orange = Color(0xFFFF8D28);
  static const yellow = Color(0xFFFFCC00);
  static const green = Color(0xFF34C759);
  static const mint = Color(0xFF00C8B3);
  static const teal = Color(0xFF00C3D0);
  static const cyan = Color(0xFF00C0E8);
  static const blue = Color(0xFF0088FF);
  static const indigo = Color(0xFF6155F5);
  static const purple = Color(0xFFCB30E0);
  static const pink = Color(0xFFFF2D55);
  static const brown = Color(0xFFAC7F5E);

  // Dark appearance
  static const redDark = Color(0xFFFF4245);
  static const orangeDark = Color(0xFFFF9230);
  static const yellowDark = Color(0xFFFFD600);
  static const greenDark = Color(0xFF30D158);
  static const mintDark = Color(0xFF00DAC3);
  static const tealDark = Color(0xFF00D2E0);
  static const cyanDark = Color(0xFF3CD3FE);
  static const blueDark = Color(0xFF0091FF);
  static const indigoDark = Color(0xFF6D7CFF);
  static const purpleDark = Color(0xFFDB34F2);
  static const pinkDark = Color(0xFFFF375F);
  static const brownDark = Color(0xFFB78A66);

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBackground,
    primaryColor: lightPrimary,
    cardColor: lightCard,
    fontFamily: _fontFamily,
    appBarTheme: const AppBarTheme(
      backgroundColor: lightAppBar,
      foregroundColor: lightBackground,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: lightTextPrimary,
      ),
      displayMedium: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: lightTextPrimary,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: lightTextPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: lightTextPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: lightTextPrimary,
      ),
      titleSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: lightTextPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.normal,
        color: lightTextPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: lightTextPrimary,
      ),
      bodySmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: lightTextSecondary,
      ),
      labelSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: lightTextSecondary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightPrimary,
        foregroundColor: lightBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightPrimary, width: 1),
        ),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    primaryColor: darkPrimary,
    cardColor: darkCard,
    fontFamily: _fontFamily,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkAppBar,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: darkTextPrimary,
      ),
      displayMedium: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: darkTextPrimary,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: darkTextPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.normal,
        color: darkTextPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: darkTextPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: darkTextPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: darkTextPrimary,
      ),
      bodySmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: darkTextSecondary,
      ),
      labelSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: darkTextSecondary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkPrimary, width: 1),
        ),
      ),
    ),
  );
}
