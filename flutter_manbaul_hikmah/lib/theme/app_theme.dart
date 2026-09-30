import 'package:flutter/material.dart';

class AppTheme {
  // Gojek Signature Colors
  static const Color gojekGreen = Color(0xFF00AA13);
  static const Color gojekDarkGreen = Color(0xFF00880C);
  static const Color gojekLightGreen = Color(0xFFE6F8E8);
  static const Color gojekSurface = Color(0xFFF6FBF7);
  
  // GoPay Signature Colors
  static const Color gopayBlue = Color(0xFF0081A0);
  static const Color gopayCard = Color(0xFF005D74);
  static const Color gopayBadge = Color(0xFF38BDF8);

  // Neutral Colors
  static const Color background = Color(0xFFF4F6F9);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textGrey = Color(0xFF64748B);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: gojekGreen,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: gojekGreen,
        primary: gojekGreen,
        secondary: gopayBlue,
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: gojekGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.06),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gojekGreen,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
