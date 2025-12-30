import 'package:flutter/material.dart';
import '../../features/payments/domain/models/payment_model.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

class PaymentCard extends StatelessWidget {
  /// The payment to display
  final PaymentModel payment;

  /// Optional callback when card is tapped
  final VoidCallback? onTap;

  const PaymentCard({
    Key? key,
    required this.payment,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine if this is a credit (money in) or debit (money out)
    final bool isCredit = payment.isCredit;

    // Get appropriate icon
    final IconData icon = _getPaymentIcon();

    // Get amount color (green for credit, red for debit)
    final Color amountColor = isCredit
        ? AppColors.success
        : AppColors.textPrimary;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center, // Align items to center vertically
            children: [
              // Left side: Icon in circle
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getIconBackgroundColor(),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: _getIconColor(),
                  size: 24,
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // Middle: Description, date, and payment method
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Description
                    Text(
                      payment.description,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),

                    const SizedBox(height: 2),

                    // Date and payment method
                    Flexible(
                      child: Text(
                        '${payment.formattedDate} • ${payment.formattedTime}',
                        style: AppTextStyles.caption,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Payment method and status
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Text(
                            payment.paymentMethod,
                            style: AppTextStyles.captionSmall,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text('•', style: AppTextStyles.captionSmall),
                          const SizedBox(width: AppSpacing.xs),
                          _buildStatusBadge(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // Right side: Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${isCredit ? '+' : '-'} ${payment.formattedAmount}',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: amountColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get icon based on payment type
  IconData _getPaymentIcon() {
    switch (payment.type) {
      case PaymentType.topUp:
        return Icons.add_circle_outline;
      case PaymentType.trip:
        return Icons.directions_bus;
      case PaymentType.refund:
        return Icons.replay_circle_filled_outlined;
    }
  }

  /// Get icon color based on payment type
  Color _getIconColor() {
    switch (payment.type) {
      case PaymentType.topUp:
        return AppColors.success;
      case PaymentType.trip:
        return AppColors.primary;
      case PaymentType.refund:
        return AppColors.info;
    }
  }

  /// Get icon background color
  Color _getIconBackgroundColor() {
    switch (payment.type) {
      case PaymentType.topUp:
        return AppColors.success.withOpacity(0.1);
      case PaymentType.trip:
        return AppColors.primary.withOpacity(0.1);
      case PaymentType.refund:
        return AppColors.info.withOpacity(0.1);
    }
  }

  /// Build status badge
  Widget _buildStatusBadge() {
    Color badgeColor;
    switch (payment.status) {
      case PaymentStatus.success:
        badgeColor = AppColors.success;
        break;
      case PaymentStatus.failed:
        badgeColor = AppColors.error;
        break;
      case PaymentStatus.pending:
        badgeColor = AppColors.warning;
        break;
      case PaymentStatus.cancelled:
        badgeColor = AppColors.textTertiary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        payment.status.displayName,
        style: AppTextStyles.captionSmall.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}