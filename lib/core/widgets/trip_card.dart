import 'package:flutter/material.dart';
import '../../features/activity/domain/models/trip_model.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

class TripCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback? onTap;

  const TripCard({
    Key? key,
    required this.trip,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Route & Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      trip.routeName,
                      style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusBadge(),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Visual Route Line
              _buildRouteTimeline(),

              const SizedBox(height: AppSpacing.md),

              // Bottom Info: Date, Time, Passengers & Fare
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(trip.formattedDate, style: AppTextStyles.caption),
                          const SizedBox(width: 8),
                          const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(trip.departureTime, style: AppTextStyles.caption),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.people_outline, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text('${trip.passengers} Passenger(s)', style: AppTextStyles.caption),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    'KES ${trip.fare.toStringAsFixed(0)}',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
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

  Widget _buildRouteTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.circle, size: 10, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(trip.startLocation, style: AppTextStyles.bodyMedium),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Container(
            width: 1,
            height: 15,
            color: AppColors.border.withOpacity(0.5),
          ),
        ),
        Row(
          children: [
            const Icon(Icons.location_on, size: 12, color: AppColors.error),
            const SizedBox(width: 10),
            Text(trip.endLocation, style: AppTextStyles.bodyMedium),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final color = Color(trip.status.colorValue);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        trip.status.displayName,
        style: AppTextStyles.labelMedium.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}