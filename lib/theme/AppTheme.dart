import 'package:flutter/material.dart';
import 'dart:math' as math;

class AppTheme {
  // Primary colors - More balanced palette
  static const Color primaryTeal = Color(0xFF26A69A); // Professional teal
  static const Color accentGreen = Color(0xFF2E7D32); // Forest green
  static const Color lightTeal = Color(0xFF4DB6AC); // Soft teal
  static const Color warmAccent = Color(0xFF00ACC1); // Cyan accent

  // Warm complementary colors
  static const Color coralPink = Color(0xFFFF7043); // Warm coral
  static const Color amberGold = Color(0xFFFFB300); // Rich amber
  static const Color lavender = Color(0xFF7986CB); // Soft lavender
  static const Color sage = Color(0xFF81C784); // Sage green

  // Neutral and surface colors
  static const Color background = Color(0xFFFAFAFA); // Warm off-white
  static const Color surface = Color(0xFFFFFFFF); // Pure white
  static const Color surfaceVariant = Color(0xFFF5F5F5); // Light grey
  static const Color onSurface = Color(0xFF212121); // Dark grey
  static const Color onSurfaceVariant = Color(0xFF616161); // Medium grey
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color shadowColor = Color(0xFF000000);

  // Status colors
  static const Color success = Color(0xFF2E7D32); // Success green
  static const Color warning = Color(0xFFFFB300); // Warning amber
  static const Color error = Color(0xFFD32F2F); // Error red
  static const Color info = Color(0xFF1976D2); // Info blue

  // Gradient combinations for different sections
  static const List<Color> primaryGradient = [primaryTeal, lightTeal];
  static const List<Color> accentGradient = [sage, accentGreen];
  static const List<Color> warmGradient = [coralPink, amberGold];
  static const List<Color> coolGradient = [lavender, warmAccent];

  // Specialized gradients
  static const List<Color> performanceGradient = [success, sage];
  static const List<Color> analyticsGradient = [lightTeal, lavender];
  static const List<Color> chartGradient = [primaryTeal, warmAccent];
  static const List<Color> rankingGradient = [amberGold, coralPink];
  static const List<Color> cardGradient = [surface, surfaceVariant];

  // Enhanced chart colors with better contrast and variety
  static const List<Color> chartColors = [
    primaryTeal,    // Teal
    coralPink,      // Coral
    lightTeal,  // Blue
    amberGold,      // Amber
    accentGreen,    // Green
    lavender,       // Lavender
    Color(0xFF8D6E63), // Brown
    Color(0xFF546E7A), // Blue grey
    Color(0xFFAD1457), // Pink
    Color(0xFF6A1B9A), // Purple
  ];

  // Medal gradients
  static const List<Color> goldGradient = [Color(0xFFFFD700), Color(0xFFFFF176)];
  static const List<Color> silverGradient = [Color(0xFFC0C0C0), Color(0xFFE0E0E0)];
  static const List<Color> bronzeGradient = [Color(0xFFCD7F32), Color(0xFFFFAB40)];
  static const List<Color> lavenderGradient = [
    Color(0xFF9FA8DA), // Light Lavender
    Color(0xFF7986CB), // Base Lavender
  ];



  // Spacing constants
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 12.0;
  static const double paddingLarge = 16.0;
  static const double paddingXLarge = 24.0;
  static const double marginSmall = 6.0;
  static const double marginMedium = 8.0;
  static const double marginLarge = 12.0;
  static const double marginXLarge = 20.0;

  // Enhanced text styles with better hierarchy
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );
  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
  );
  static const TextStyle titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.25,
  );
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  // Helper methods for creating gradients
  static LinearGradient createGradient(List<Color> colors, {
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      colors: colors,
      begin: begin,
      end: end,
    );
  }

  static LinearGradient get verticalPrimaryGradient => LinearGradient(
    colors: primaryGradient,
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient get horizontalAccentGradient => LinearGradient(
    colors: accentGradient,
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Enhanced theme configuration
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryTeal,
    scaffoldBackgroundColor: background,

    colorScheme: const ColorScheme.light(
      primary: primaryTeal,
      onPrimary: Colors.white,
      secondary: coralPink,
      onSecondary: Colors.white,
      tertiary: sage,
      onTertiary: Colors.white,
      surface: surface,
      onSurface: onSurface,
      background: background,
      onBackground: onSurface,
      error: error,
      onError: Colors.white,
      outline: onSurfaceVariant,
      surfaceVariant: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
    ),

    cardTheme: CardTheme(
      color: cardColor,
      elevation: 6,
      shadowColor: primaryTeal.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: marginMedium,
        vertical: marginSmall,
      ),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 4,
      titleTextStyle: TextStyle(
        color: onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      iconTheme: IconThemeData(color: primaryTeal),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 3,
        shadowColor: primaryTeal.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: paddingLarge,
          vertical: paddingMedium,
        ),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: coralPink,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryTeal,
        side: const BorderSide(color: primaryTeal),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: onSurfaceVariant.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: onSurfaceVariant.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryTeal, width: 2),
      ),
      filled: true,
      fillColor: surfaceVariant,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: surfaceVariant,
      selectedColor: primaryTeal.withOpacity(0.15),
      labelStyle: const TextStyle(color: onSurface),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}