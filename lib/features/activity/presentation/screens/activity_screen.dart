import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/trip_provider.dart';
import '../../domain/models/trip_model.dart';
import '../../../../core/widgets/trip_card.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ==================== BOOKING DRAWER ====================
  void _showBookingDrawer() {
    String from = "Busia";
    String to = "Nairobi";
    String time = "08:00 AM";
    int passengers = 1;
    double pricePerPerson = 1200.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Plan New Trip', style: AppTextStyles.headingMedium),
              const SizedBox(height: 20),
              _buildLocationSelector("From", from, (val) => setSheetState(() => from = val)),
              _buildLocationSelector("To", to, (val) => setSheetState(() => to = val)),
              const Divider(),
              ListTile(
                title: const Text("Departure Time"),
                subtitle: const Text("Static schedule"),
                trailing: DropdownButton<String>(
                  value: time,
                  items: ["08:00 AM", "08:00 PM"]
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) => setSheetState(() => time = val!),
                ),
              ),
              ListTile(
                title: const Text("Number of Passengers"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => setSheetState(() => passengers > 1 ? passengers-- : null)),
                    Text("$passengers", style: AppTextStyles.bodyLarge),
                    IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => setSheetState(() => passengers++)),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text("Est. Travel Time: 9 Hours", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
              ),
              const SizedBox(height: 20),
              // Main Action: Pay and Book
              CustomButton(
                text: "Confirm & Pay KES ${pricePerPerson * passengers}",
                onPressed: () async {
                  final newTrip = TripModel(
                    id: 'trip_${DateTime.now().millisecondsSinceEpoch}',
                    routeName: '$from to $to',
                    startLocation: from,
                    endLocation: to,
                    date: DateTime.now(),
                    departureTime: time,
                    fare: pricePerPerson * passengers,
                    passengers: passengers,
                    status: TripStatus.pending,
                    paymentMethod: 'Wallet',
                    vehicleNumber: 'KCJ ${100 + Random().nextInt(800)}W',
                  );
                  try {
                    await ref.read(tripStateProvider.notifier).bookTrip(newTrip);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Trip booked! Tracking status...")));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                  }
                },
              ),
              const SizedBox(height: 12),
              // Secondary Action: Cancel/Close Drawer
              CustomButton(
                text: "Cancel",
                type: ButtonType.outlined,
                color: AppColors.textSecondary,
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationSelector(String label, String value, Function(String) onChanged) {
    final cities = ["Nairobi", "Busia", "Mombasa", "Kisumu", "Eldoret"];
    return ListTile(
      title: Text(label),
      trailing: DropdownButton<String>(
        value: value,
        items: cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
        onChanged: (val) => onChanged(val!),
      ),
    );
  }

  // ==================== TRIP DETAILS DIALOG ====================
  void _showTripDetails(TripModel trip) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Trip Summary', style: AppTextStyles.headingMedium),
                _buildStatusChip(trip),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow("Route", trip.routeName),
            _buildDetailRow("Time", trip.departureTime),
            _buildDetailRow("Fare Paid", "KES ${trip.fare}"),
            if (trip.failureReason != null)
              _buildDetailRow("Failure Reason", trip.failureReason!, color: Colors.red),
            const SizedBox(height: 25),

            // Cancellation Button Logic
            if (trip.status == TripStatus.pending)
              CustomButton(
                text: "Cancel Trip",
                // Use the new color parameter we added to CustomButton
                color: trip.canCancel ? Colors.red : Colors.grey,
                onPressed: trip.canCancel ? () {
                  ref.read(tripStateProvider.notifier).cancelTrip(trip.id);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Trip cancelled successfully"))
                  );
                } : null, // Disables button if less than 1hr remains
              ),

            if (trip.status == TripStatus.pending && !trip.canCancel)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text("Cannot cancel within 1 hour of departure",
                      style: TextStyle(color: Colors.red, fontSize: 12)),
                ),
              ),

            // Close details button
            if (trip.status != TripStatus.pending)
              CustomButton(
                text: "Close",
                onPressed: () => Navigator.pop(context),
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(TripModel trip) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Color(trip.status.colorValue).withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(trip.status.displayName,
          style: TextStyle(color: Color(trip.status.colorValue), fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final tripsAsync = ref.watch(tripStateProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Trip Activity'), automaticallyImplyLeading: false),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            if (user != null) _buildStatisticsCard(user.id),
            Expanded(
              child: tripsAsync.when(
                data: (trips) {
                  if (trips.isEmpty) return const EmptyState(icon: Icons.directions_bus, title: "No Trips Yet", message: "Book your first trip below");
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: trips.length,
                    itemBuilder: (context, index) => TripCard(
                      trip: trips[index],
                      onTap: () => _showTripDetails(trips[index]),
                    ),
                  );
                },
                loading: () => const LoadingIndicator(),
                error: (e, _) => Center(child: Text(e.toString())),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showBookingDrawer,
        label: const Text("Book a Trip", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildStatisticsCard(String userId) {
    final stats = ref.watch(tripStatisticsProvider(userId));
    return stats.when(
      data: (s) => Container(
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem("Trips", s['total_trips'].toString()),
            _buildStatItem("Spent", "KES ${s['total_spent'].toStringAsFixed(0)}"),
          ],
        ),
      ),
      loading: () => const SizedBox(height: 80, child: LoadingIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.headingMedium),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}