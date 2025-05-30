import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors
  static const lightBackground = Color(0xFFF5F7FA);
  static const lightCardBackground = Colors.white;
  static const lightAccent = Color(0xFF4285F4);
  static const lightTextColor = Color(0xFF202124);

  // Dark Theme Colors
  static const darkBackground = Color(0xFF1A1D21);
  static const darkCardBackground = Color(0xFF252A31);
  static const darkAccent = Color(0xFF8AB4F8);
  static const darkTextColor = Color(0xFFE8EAED);

  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBackground
        : lightBackground;
  }

  static Color cardBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkCardBackground
        : lightCardBackground;
  }

  static Color accent(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkAccent
        : lightAccent;
  }

  static Color textColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextColor
        : lightTextColor;
  }
}

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.lightBackground,
    primaryColor: AppColors.lightAccent,
    cardColor: AppColors.lightCardBackground,
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightAccent,
      secondary: AppColors.lightAccent,
      background: AppColors.lightBackground,
      surface: AppColors.lightCardBackground,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.lightTextColor),
      bodyMedium: TextStyle(color: AppColors.lightTextColor),
      displayLarge: TextStyle(color: AppColors.lightTextColor),
      displayMedium: TextStyle(color: AppColors.lightTextColor),
      displaySmall: TextStyle(color: AppColors.lightTextColor),
      headlineMedium: TextStyle(color: AppColors.lightTextColor),
      titleLarge: TextStyle(color: AppColors.lightTextColor),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: AppColors.lightBackground,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.lightAccent),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.lightAccent,
        side: const BorderSide(color: AppColors.lightAccent, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.darkBackground,
    primaryColor: AppColors.darkAccent,
    cardColor: AppColors.darkCardBackground,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkAccent,
      secondary: AppColors.darkAccent,
      background: AppColors.darkBackground,
      surface: AppColors.darkCardBackground,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.darkTextColor),
      bodyMedium: TextStyle(color: AppColors.darkTextColor),
      displayLarge: TextStyle(color: AppColors.darkTextColor),
      displayMedium: TextStyle(color: AppColors.darkTextColor),
      displaySmall: TextStyle(color: AppColors.darkTextColor),
      headlineMedium: TextStyle(color: AppColors.darkTextColor),
      titleLarge: TextStyle(color: AppColors.darkTextColor),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: AppColors.darkCardBackground,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF3D3D3D)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF3D3D3D)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.darkAccent),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkAccent,
        foregroundColor: AppColors.darkBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.darkAccent,
        side: const BorderSide(color: AppColors.darkAccent, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
  );
}
