import 'package:flutter/material.dart';

/// SubSentinel Design System Colors
/// "Neon-Safety" palette for high visibility on OLED screens
class AppColors {
  // Canvas Colors
  static const Color canvas = Color(0xFF000000); // Pure Black - OLED efficiency
  static const Color primaryCard = Color(
    0xFF121212,
  ); // Eerie Black - Card boundaries

  // Accent Colors - "Neon-Safety" palette
  static const Color active = Color(0xFF00FF41); // Neon Green - Active state
  static const Color alert = Color(0xFFFF3131); // Neon Red - Alert/Warning
  static const Color paused = Color(0xFFFFD700); // Gold - Paused state
  static const Color scanLine = Color(0xFF00D4FF); // Neon Blue - Scanner laser

  // Glass/Blur Colors
  static const Color glassBackground = Color(0x14FFFFFF); // 8% white opacity
  static const Color glassBorder = Color(0x1AFFFFFF); // 10% white opacity

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF6B6B6B);

  // Gradient Colors for Burn Gauge
  static const Color burnStart = Color(0xFF00FF41); // Green (start of month)
  static const Color burnMid = Color(0xFFFFD700); // Gold (mid-month)
  static const Color burnEnd = Color(
    0xFFFF3131,
  ); // Red (end of month/over-budget)

  // Shimmer Colors for Skeleton Loading
  static const Color shimmerBase = Color(0xFF1A1A1A);
  static const Color shimmerHighlight = Color(0xFF2A2A2A);

  // ─────────────────────────────────────────────
  // Light Theme — "Clean Sentinel" palette
  // ─────────────────────────────────────────────

  // Canvas Colors
  static const Color lightCanvas = Color(
    0xFFF2F2F7,
  ); // System Gray 6 - iOS inspired
  static const Color lightPrimaryCard = Color(0xFFFFFFFF); // Pure White cards

  // Accent Colors – slightly deeper for contrast on light surfaces
  static const Color lightActive = Color(0xFF00C637); // Vivid Green
  static const Color lightAlert = Color(0xFFE5202A); // Strong Red
  static const Color lightPaused = Color(0xFFE5A100); // Amber Gold
  static const Color lightScanLine = Color(0xFF009FC7); // Deep Cyan

  // Glass/Blur Colors
  static const Color lightGlassBackground = Color(
    0x14000000,
  ); // 8% black opacity
  static const Color lightGlassBorder = Color(0x1A000000); // 10% black opacity

  // Text Colors
  static const Color lightTextPrimary = Color(0xFF000000);
  static const Color lightTextSecondary = Color(0xFF3C3C43);
  static const Color lightTextMuted = Color(0xFF8E8E93);

  // Gradient Colors for Burn Gauge
  static const Color lightBurnStart = Color(0xFF00C637); // Green
  static const Color lightBurnMid = Color(0xFFE5A100); // Amber Gold
  static const Color lightBurnEnd = Color(0xFFE5202A); // Red

  // Shimmer Colors for Skeleton Loading
  static const Color lightShimmerBase = Color(0xFFE8E8ED);
  static const Color lightShimmerHighlight = Color(0xFFF5F5FA);

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color canvasFor(BuildContext context) =>
      isDark(context) ? canvas : lightCanvas;

  static Color surfaceFor(BuildContext context) =>
      isDark(context) ? primaryCard : lightPrimaryCard;

  static Color glassBorderFor(BuildContext context) =>
      isDark(context) ? glassBorder : lightGlassBorder;

  static Color glassBackgroundFor(BuildContext context) =>
      isDark(context) ? glassBackground : lightGlassBackground;

  static Color textPrimaryFor(BuildContext context) =>
      isDark(context) ? textPrimary : lightTextPrimary;

  static Color textSecondaryFor(BuildContext context) =>
      isDark(context) ? textSecondary : lightTextSecondary;

  static Color textMutedFor(BuildContext context) =>
      isDark(context) ? textMuted : lightTextMuted;

  static Color shimmerBaseFor(BuildContext context) =>
      isDark(context) ? shimmerBase : lightShimmerBase;

  static Color shimmerHighlightFor(BuildContext context) =>
      isDark(context) ? shimmerHighlight : lightShimmerHighlight;
}
