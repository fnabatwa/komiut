import 'dart:async';
import '../../domain/models/trip_model.dart';

class TripService {
  final List<TripModel> _mockTrips = [
    TripModel(
      id: 'trip_001',
      routeName: 'Nairobi to Busia',
      startLocation: 'Nairobi',
      endLocation: 'Busia',
      date: DateTime.now().subtract(const Duration(days: 1)),
      departureTime: '08:00 AM',
      passengers: 1,
      fare: 1200.0,
      status: TripStatus.completed,
      paymentMethod: 'Wallet',
      vehicleNumber: 'KCB 234X',
    ),
    TripModel(
      id: 'trip_002',
      routeName: 'Busia to Nairobi',
      startLocation: 'Busia',
      endLocation: 'Nairobi',
      date: DateTime.now().subtract(const Duration(days: 2)),
      departureTime: '08:00 PM',
      passengers: 2,
      fare: 2400.0,
      status: TripStatus.completed,
      paymentMethod: 'Wallet',
      vehicleNumber: 'KCD 567Y',
    ),
  ];

  Future<List<TripModel>> getUserTrips(String userId) async {
    await Future.delayed(const Duration(seconds: 1));
    return _mockTrips;
  }

  Future<List<TripModel>> getRecentTrips(String userId, {int limit = 5}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final allTrips = List<TripModel>.from(_mockTrips);
    allTrips.sort((a, b) => b.date.compareTo(a.date));
    return allTrips.take(limit).toList();
  }

  // Updated to include the new required fields
  Future<TripModel> createTrip({
    required String routeName,
    required String startLocation,
    required String endLocation,
    required double fare,
    required String departureTime,
    required int passengers,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    final newTrip = TripModel(
      id: 'trip_${DateTime.now().millisecondsSinceEpoch}',
      routeName: routeName,
      startLocation: startLocation,
      endLocation: endLocation,
      date: DateTime.now(),
      departureTime: departureTime,
      passengers: passengers,
      fare: fare,
      status: TripStatus.pending,
      paymentMethod: 'Wallet',
      vehicleNumber: 'KCA ${100 + (DateTime.now().second)}W',
    );
    _mockTrips.insert(0, newTrip);
    return newTrip;
  }

  Future<Map<String, dynamic>> getTripStatistics(String userId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final completed = _mockTrips.where((t) => t.status == TripStatus.completed).toList();
    final totalSpent = completed.fold<double>(0, (sum, t) => sum + t.fare);
    return {
      'total_trips': _mockTrips.length,
      'completed_trips': completed.length,
      'total_spent': totalSpent,
    };
  }

  Future<List<TripModel>> filterTripsByStatus(String userId, TripStatus status) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockTrips.where((t) => t.status == status).toList();
  }

  Future<TripModel?> getTripById(String tripId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _mockTrips.firstWhere((t) => t.id == tripId);
    } catch (e) {
      return null;
    }
  }
}