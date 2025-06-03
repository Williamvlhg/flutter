import 'package:flutter/material.dart';

class SimpsonsColors {
  static const Color yellow = Color(0xFFFFD700);
  static const Color blue = Color(0xFF1E90FF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkBlue = Color(0xFF0066CC);
  static const Color lightYellow = Color(0xFFFFF8DC);
  static const Color orange = Color(0xFFFF8C00);
}

class SimpsonsTheme {
  static ThemeData get theme {
    return ThemeData(
      primarySwatch: MaterialColor(0xFFFFD700, {
        50: SimpsonsColors.lightYellow,
        100: SimpsonsColors.yellow.withOpacity(0.1),
        200: SimpsonsColors.yellow.withOpacity(0.2),
        300: SimpsonsColors.yellow.withOpacity(0.3),
        400: SimpsonsColors.yellow.withOpacity(0.4),
        500: SimpsonsColors.yellow,
        600: SimpsonsColors.yellow.withOpacity(0.6),
        700: SimpsonsColors.yellow.withOpacity(0.7),
        800: SimpsonsColors.yellow.withOpacity(0.8),
        900: SimpsonsColors.yellow.withOpacity(0.9),
      }),
      scaffoldBackgroundColor: SimpsonsColors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: SimpsonsColors.yellow,
        foregroundColor: SimpsonsColors.darkBlue,
        elevation: 4,
        titleTextStyle: TextStyle(
          color: SimpsonsColors.darkBlue,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SimpsonsColors.blue,
          foregroundColor: SimpsonsColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: SimpsonsColors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: SimpsonsColors.yellow, width: 2),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: SimpsonsColors.darkBlue,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: SimpsonsColors.darkBlue,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: Colors.black87,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: Colors.black87,
          fontSize: 14,
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: SimpsonsColors.yellow,
        secondary: SimpsonsColors.blue,
        surface: SimpsonsColors.white,
        onPrimary: SimpsonsColors.darkBlue,
        onSecondary: SimpsonsColors.white,
        onSurface: Colors.black87,
      ),
    );
  }
}
