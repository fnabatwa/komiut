import 'package:intl/intl.dart';

enum TripStatus { completed, failed, pending, cancelled }

extension TripStatusExtension on TripStatus {
  String get displayName {
    switch (this) {
      case TripStatus.completed: return 'Completed';
      case TripStatus.failed: return 'Failed';
      case TripStatus.pending: return 'Pending';
      case TripStatus.cancelled: return 'Cancelled';
    }
  }

  int get colorValue {
    switch (this) {
      case TripStatus.completed: return 0xFF10B981;
      case TripStatus.failed: return 0xFFEF4444;
      case TripStatus.pending: return 0xFFF59E0B;
      case TripStatus.cancelled: return 0xFF6B7280;
    }
  }
}

class TripModel {
  final String id;
  final String routeName;
  final String startLocation;
  final String endLocation;
  final DateTime date;
  final String departureTime; // "08:00 AM" or "08:00 PM"
  final double fare;
  final int passengers;
  final TripStatus status;
  final String paymentMethod;
  final String? vehicleNumber;
  final String? failureReason;

  TripModel({
    required this.id,
    required this.routeName,
    required this.startLocation,
    required this.endLocation,
    required this.date,
    required this.departureTime,
    required this.fare,
    required this.passengers,
    required this.status,
    required this.paymentMethod,
    this.vehicleNumber,
    this.failureReason,
  });

  // Business Rule: Cannot cancel 1 hour before departure
  bool get canCancel {
    if (status != TripStatus.pending) return false;

    final now = DateTime.now();
    // Parse departureTime string to get hour
    int hour = departureTime.contains('PM') ? 20 : 8;
    final tripStart = DateTime(date.year, date.month, date.day, hour);

    return tripStart.difference(now).inHours >= 1;
  }

  String get formattedDate => DateFormat('MMM dd, yyyy').format(date);

  // CopyWith helper to update status easily in StateNotifier
  TripModel copyWith({TripStatus? status, String? failureReason}) {
    return TripModel(
      id: id,
      routeName: routeName,
      startLocation: startLocation,
      endLocation: endLocation,
      date: date,
      departureTime: departureTime,
      fare: fare,
      passengers: passengers,
      status: status ?? this.status,
      paymentMethod: paymentMethod,
      vehicleNumber: vehicleNumber,
      failureReason: failureReason ?? this.failureReason,
    );
  }
}