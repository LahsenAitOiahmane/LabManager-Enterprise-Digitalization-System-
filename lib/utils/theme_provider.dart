import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('dark_mode') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _isDarkMode);
    notifyListeners();
  }

  ThemeData get themeData => _isDarkMode 
      ? _darkTheme 
      : _lightTheme;

  final _lightTheme = ThemeData(
    primaryColor: const Color(0xFFC1F11D),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFC1F11D),
      primary: const Color(0xFFC1F11D),
      secondary: const Color(0xFF2FDD92),
      background: const Color(0xFFF5F5F5),
      error: const Color(0xFFFF4D4F),
      brightness: Brightness.light,
    ),
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFC1F11D),
      foregroundColor: Color(0xFF2C2C2C),
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFC1F11D),
        foregroundColor: const Color(0xFF2C2C2C),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF667632),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textTheme: const TextTheme(
      labelLarge: TextStyle(
        color: Color(0xFFC1F11D),
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  final _darkTheme = ThemeData(
    primaryColor: const Color(0xFFC1F11D),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFC1F11D),
      primary: const Color(0xFFC1F11D),
      secondary: const Color(0xFF2FDD92),
      background: const Color(0xFF121212),
      onBackground: Colors.white,
      surface: const Color(0xFF1E1E1E),
      onSurface: Colors.white,
      error: const Color(0xFFFF4D4F),
      brightness: Brightness.dark,
    ),
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardColor: const Color(0xFF1E1E1E),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF90CAF9),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textTheme: const TextTheme(
      labelLarge: TextStyle(
        color: Color(0xFF90CAF9),
        fontWeight: FontWeight.w600,
      ),
    ),
  );
} 