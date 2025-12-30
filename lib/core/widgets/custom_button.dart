import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonType type;
  final IconData? icon;
  final bool fullWidth;

  // Optional color parameter to override theme (e.g., Colors.red)
  final Color? color;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.type = ButtonType.primary,
    this.icon,
    this.fullWidth = true,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget buttonChild = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                type == ButtonType.outlined
                    ? (color ?? theme.colorScheme.primary)
                    : Colors.white,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        if (icon != null && !isLoading) ...[
          Icon(icon, size: AppSpacing.iconSM),
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    // Build the appropriate button type with color overrides
    switch (type) {
      case ButtonType.primary:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          child: ElevatedButton(
            // Use the custom color if provided, otherwise uses theme
            style: color != null
                ? ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white)
                : null,
            onPressed: isLoading ? null : onPressed,
            child: buttonChild,
          ),
        );

      case ButtonType.secondary:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          child: TextButton(
            style: color != null ? TextButton.styleFrom(foregroundColor: color) : null,
            onPressed: isLoading ? null : onPressed,
            child: buttonChild,
          ),
        );

      case ButtonType.outlined:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          child: OutlinedButton(
            style: color != null ? OutlinedButton.styleFrom(side: BorderSide(color: color!), foregroundColor: color) : null,
            onPressed: isLoading ? null : onPressed,
            child: buttonChild,
          ),
        );
    }
  }
}

enum ButtonType {
  primary,
  secondary,
  outlined,
}