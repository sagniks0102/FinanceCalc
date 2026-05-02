import 'package:flutter/material.dart';

extension ThemeContext on BuildContext {
  Color get bg => Theme.of(this).scaffoldBackgroundColor;
  Color get card => Theme.of(this).colorScheme.surface;
  Color get text => Theme.of(this).colorScheme.onSurface;
  Color get textSub => Theme.of(this).colorScheme.onSurfaceVariant;
  Color get border => Theme.of(this).colorScheme.outlineVariant;
  
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Slate 50
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF6366F1), // Indigo 500
        surface: Colors.white,
        onSurface: Color(0xFF0F172A), // Slate 900
        onSurfaceVariant: Color(0xFF475569), // Slate 600
        outlineVariant: Color(0xFFE2E8F0), // Slate 200
      ),
      useMaterial3: true,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF8FAFC),
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF0F172A)),
        titleTextStyle: TextStyle(color: Color(0xFF0F172A), fontSize: 22, fontWeight: FontWeight.w700),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF111827), // Gray 900
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF6366F1), // Indigo 500
        surface: Color(0xFF1E293B), // Slate 800
        onSurface: Colors.white,
        onSurfaceVariant: Color(0xFF94A3B8), // Slate 400
        outlineVariant: Color(0xFF334155), // Slate 700
      ),
      useMaterial3: true,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF111827),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
      ),
    );
  }
}
