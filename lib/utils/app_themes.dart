import 'package:flutter/material.dart';

class AppThemes {
  // Fleet-themed light mode
  static final light = ThemeData(
    primaryColor: const Color(0xFF0D47A1), // Navy blue
    scaffoldBackgroundColor: Colors.white,
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(
        color: Colors.black,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF0D47A1),
      primary: const Color(0xFF0D47A1),
      secondary: const Color(0xFF26A69A),
      brightness: Brightness.light,
      surface: Colors.white,
    ),
    cardColor: Colors.grey[100],
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF0D47A1),
      unselectedItemColor: Colors.grey,
    ),
  );

  // Fleet-themed dark mode
  static final dark = ThemeData(
    primaryColor: const Color(0xFF0D47A1),
    scaffoldBackgroundColor: const Color(0xFF121212),
    brightness: Brightness.dark,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212),
      elevation: 0,
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF0D47A1),
      primary: const Color(0xFF0D47A1),
      secondary: const Color(0xFF26A69A),
      brightness: Brightness.dark,
      surface: const Color(0xFF1E1E1E),
    ),
    cardColor: const Color(0xFF1E1E1E),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: Color(0xFF26A69A),
      unselectedItemColor: Colors.grey,
    ),
  );
}
