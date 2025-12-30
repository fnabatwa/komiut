import 'package:flutter/material.dart';

/// in this file, all the colors used in the app is defined here
class AppColors {
  AppColors._();

  // ==================== PRIMARY BRAND COLORS ====================
  /// primary - blue : for brand color, buttons, links, highlights
  static const Color primary = Color(0xFF2563EB);

  /// darker blue shade for when primary is pressed
  static const Color primaryDark = Color(0xFF1E40AF);

  /// light blue for backgrounds, hover states
  static const Color primaryLight = Color(0xFF93C5FD);

  // ==================== SECONDARY COLORS ====================
  /// green represents success ; positive actions
  static const secondary = Color(0xFF10B981);

  ///darker green - pressed state
  static const secondaryDark = Color(0xFF059669);

  /// light green - background for success messages
  static const secondaryLight = Color(0xFF6EE7B7);

  // ==================== TEXT COLORS (LIGHT MODE) ==================
  /// main text color - dark gray, used for headings and body text
  static const Color textPrimary = Color(0xFF1F2937);

  /// Secondary text - medium gray, used for descriptions
  static const Color textSecondary = Color(0xFF6B7280);

  /// Tertiary text - light gray, used for hints and placeholders
  static const Color textTertiary = Color(0xFF9CA3AF);

  // ==================== BACKGROUND COLORS (LIGHT MODE) ====================
  /// Screen background - very light gray (off-white)
  static const Color background = Color(0xFFFAFAFA);

  /// White surface - used for cards, containers
  static const Color surface = Color(0xFFFFFFFF);

  /// Alternate surface - light gray for variety
  static const Color surfaceVariant = Color(0xFFF3F4F6);

  // ==================== STATUS COLORS ====================
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ==================== BORDERS & DIVIDERS ====================
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFE5E7EB);

  // ==================== OVERLAY COLORS ====================
  static const Color overlay = Color(0x80000000);

  // ==================== DARK MODE COLORS ====================
  /// Dark background - almost black
  static const Color darkBackground = Color(0xFF111827);

  /// Dark surface - dark gray for cards in dark mode
  static const Color darkSurface = Color(0xFF1F2937);

  /// Dark text - off-white for readability on dark backgrounds
  static const Color darkTextPrimary = Color(0xFFF9FAFB);

  /// NEW: Dark text secondary - muted gray-white for descriptions in dark mode
  /// This fixes the "undefined getter" error
  static const Color darkTextSecondary = Color(0xFF9CA3AF);

  /// NEW: Dark border color - subtle gray for dark mode fields
  static const Color darkBorder = Color(0xFF374151);
}