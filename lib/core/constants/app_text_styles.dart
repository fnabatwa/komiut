import 'package:flutter/material.dart';
import 'app_colors.dart'; // Updated relative import

class AppTextStyles {
  AppTextStyles._();

  // ==================== DISPLAY STYLES ====================
  /// display large -32px, Bold
  /// Use for: App name on splash, welcome messages
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    // color removed to allow Theme inheritance
    letterSpacing: -0.5,
  );

  /// display medium -28px, Bold
  /// Use for: Large headings, important announcements
  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  // ==================== HEADING STYLES ====================
  /// Heading Large - 24px, Bold
  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.3,
  );

  /// Heading Medium - 20px, Semi-bold
  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  /// Heading Small - 18px, Semi-bold
  static const TextStyle headingSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  // ==================== TITLE STYLES ====================
  /// Title Large - 16px, Semi-bold
  static const TextStyle titleLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  /// Title Medium - 14px, Medium weight
  static const TextStyle titleMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  // ==================== BODY STYLES ====================
  /// Body Large - 16px, Regular
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  /// Body Medium - 14px, Regular
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  /// Body Small - 12px, Regular
  ///  We still use textSecondary here for "muted" look, but it will be overridden by darkTextSecondary in AppTheme.darkTheme
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // ==================== LABEL STYLES ====================
  /// Label Large - 14px, Semi-bold
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  /// Label Medium - 12px, Semi-bold
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  // ==================== CAPTION STYLES ====================
  /// Caption - 12px, Regular
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  /// Caption Small - 10px, Regular
  static const TextStyle captionSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.normal,
    color: AppColors.textTertiary,
  );

  // ==================== SPECIAL STYLES ====================
  /// Button text style - 16px, Semi-bold
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
}