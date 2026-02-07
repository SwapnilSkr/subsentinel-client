import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// SubSentinel Theme Configuration
/// Premium dark theme with Inter Tight variable font
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.canvas,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.active,
        secondary: AppColors.paused,
        error: AppColors.alert,
        surface: AppColors.primaryCard,
        onPrimary: AppColors.canvas,
        onSecondary: AppColors.canvas,
        onError: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: _buildTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        color: AppColors.primaryCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.glassBorder, width: 1),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme() {
    return GoogleFonts.interTightTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontSize: 72,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: -2,
        ),
        displayMedium: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: -1,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  /// Dynamic Typography - "Burn Rate" font-weight logic
  /// Returns appropriate font weight based on spending amount
  static FontWeight getBurnRateFontWeight(double amount) {
    if (amount <= 50) {
      return FontWeight.w300; // Light
    } else if (amount <= 150) {
      return FontWeight.w500; // Medium
    } else {
      return FontWeight.w800; // Extra Bold
    }
  }
}

/// Haptic Feedback Mapping following SubSentinel SOP
class AppHaptics {
  /// Success/Save actions
  static void success() => HapticFeedback.lightImpact();

  /// Warning/Upcoming renewal alerts
  static void warning() => HapticFeedback.vibrate();

  /// Navigation actions
  static void navigation() => HapticFeedback.selectionClick();

  /// Heavy impact for destructive actions
  static void destructive() => HapticFeedback.heavyImpact();
}
