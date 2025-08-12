import 'package:flutter/material.dart';
import 'dart:math' as math;

class AppTheme {
  // Primary gradient colors - Medical Blue to Mint Green
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color medicalTeal = Color(0xFF00BCD4);
  static const Color mintGreen = Color(0xFF4CAF50);
  static const Color lightMint = Color(0xFF81C784);
  static const Color accent = Color(0xFF00E676);
  static const Color gold = Color(0xFFFFB300);
  static const Color purple = Color(0xFF9C27B0);
  static const Color orange = Color(0xFFFF9800);

  // Enhanced UI colors
  static const Color background = Color(0xFFF8FFFE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1A1A1A);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color shadowColor = Color(0xFF000000);

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 12.0;
  static const double paddingLarge = 16.0;
  static const double marginSmall = 6.0;
  static const double marginMedium = 8.0;
  static const double marginLarge = 12.0;

  static const TextStyle titleLarge = TextStyle(fontSize: 20, fontWeight: FontWeight.w700);
  static const TextStyle titleMedium = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
  static const TextStyle bodyLarge = TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
  static const TextStyle bodySmall = TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
  static const TextStyle labelSmall = TextStyle(fontSize: 10, fontWeight: FontWeight.w600);


  // Gradients
  static const List<Color> primaryGradient = [primaryBlue, medicalTeal];
  static const List<Color> accentGradient = [mintGreen, accent];
  static const List<Color> cardGradient = [Color(0xFFFFFFFF), Color(0xFFF8FFFE)];

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      secondary: medicalTeal,
      surface: surface,
      onSurface: onSurface,
      background: background,
      onBackground: onSurface,
      tertiary: mintGreen,
    ),
    cardTheme: CardTheme(
      color: cardColor,
      elevation: 8,
      shadowColor: primaryBlue.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: primaryBlue),
    ),
  );
}