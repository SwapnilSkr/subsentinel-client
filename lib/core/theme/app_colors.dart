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
}
