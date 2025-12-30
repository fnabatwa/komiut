import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

class LoadingIndicator extends StatelessWidget {
  /// Optional message to show below the spinner
  final String? message;

  /// Size of the spinner
  final double size;

  /// Color of the spinner
  final Color? color;

  /// Constructor
  const LoadingIndicator({
    Key? key,
    this.message,
    this.size = 40.0,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular progress indicator (spinning circle)
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppColors.primary,
              ),
            ),
          ),

          // Show message if provided
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              message!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// FullScreenLoadingIndicator - Takes up entire screen
class FullScreenLoadingIndicator extends StatelessWidget {
  /// Optional message to show
  final String? message;

  const FullScreenLoadingIndicator({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LoadingIndicator(message: message),
    );
  }
}

/// LoadingOverlay - Semi-transparent overlay with loading indicator
class LoadingOverlay extends StatelessWidget {
  /// Message to show
  final String? message;

  const LoadingOverlay({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.overlay, // Semi-transparent black
      child: LoadingIndicator(
        message: message,
        color: Colors.white, // White spinner on dark background
      ),
    );
  }
}