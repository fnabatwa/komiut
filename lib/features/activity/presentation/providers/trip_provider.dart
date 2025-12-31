import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/trip_model.dart';
import '../../data/services/trip_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Provides the instance of TripService
final tripServiceProvider = Provider<TripService>((ref) => TripService());

/// Global provider to handle trip-related state for the UI
final tripStateProvider = StateNotifierProvider<TripStateNotifier, AsyncValue<List<TripModel>>>((ref) {
  return TripStateNotifier(ref.read(tripServiceProvider), ref);
});

/// Dashboard-specific provider for the Home Screen
final recentTripsProvider = FutureProvider.family<List<TripModel>, String>((ref, userId) async {
  final tripsAsync = ref.watch(tripStateProvider);
  return tripsAsync.maybeWhen(
    data: (trips) => trips.take(5).toList(),
    orElse: () => ref.read(tripServiceProvider).getRecentTrips(userId, limit: 5),
  );
});

/// Mock Statistics Provider
final tripStatisticsProvider = Provider.family<AsyncValue<Map<String, dynamic>>, String>((ref, userId) {
  final tripsAsync = ref.watch(tripStateProvider);
  return tripsAsync.whenData((trips) {
    double totalSpent = trips
        .where((t) => t.status != TripStatus.cancelled)
        .fold(0.0, (sum, item) => sum + item.fare);

    return {
      'total_trips': trips.length,
      'completed_trips': trips.where((t) => t.status == TripStatus.completed).length,
      'total_spent': totalSpent,
    };
  });
});

class TripStateNotifier extends StateNotifier<AsyncValue<List<TripModel>>> {
  final TripService _tripService;
  final Ref _ref;

  TripStateNotifier(this._tripService, this._ref) : super(const AsyncValue.loading()) {
    final user = _ref.read(currentUserProvider);
    if (user != null) loadTrips(user.id);
  }

  Future<void> loadTrips(String userId) async {
    try {
      if (!state.hasValue) state = const AsyncValue.loading();
      final trips = await _tripService.getUserTrips(userId);
      state = AsyncValue.data(trips);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> bookTrip(TripModel trip) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) throw Exception('User not authenticated');

    if (user.walletBalance < trip.fare) {
      throw Exception('Insufficient balance. Please top up your wallet.');
    }

    try {
      // 1. Create trip in service
      final savedTrip = await _tripService.createTrip(
        routeName: trip.routeName,
        startLocation: trip.startLocation,
        endLocation: trip.endLocation,
        fare: trip.fare,
        departureTime: trip.departureTime,
        passengers: trip.passengers,
      );

      // 2. Deduct from Wallet Balance
      final newBalance = user.walletBalance - trip.fare;
      _ref.read(authStateProvider.notifier).updateWalletBalance(newBalance);

      // 3. Update the list state immediately
      state.whenData((trips) {
        state = AsyncValue.data([savedTrip, ...trips]);
      });

      // 4. Start the 20-second simulation
      _simulateTripProgress(savedTrip.id);

    } catch (e) {
      rethrow;
    }
  }

  void _simulateTripProgress(String tripId) async {
    // 20 sec wait simulation
    await Future.delayed(const Duration(seconds: 20));

    state.whenData((trips) {
      state = AsyncValue.data(trips.map((t) {
        if (t.id == tripId && t.status == TripStatus.pending) {
          // 20% failure rate simulation
          final bool willFail = Random().nextInt(100) < 20;
          return t.copyWith(
            status: willFail ? TripStatus.failed : TripStatus.completed,
            failureReason: willFail ? 'Broken tire near Naivasha' : null,
          );
        }
        return t;
      }).toList());
    });

    // Refresh dashboard
    final user = _ref.read(currentUserProvider);
    if (user != null) _ref.invalidate(recentTripsProvider(user.id));
  }

  void cancelTrip(String tripId) {
    state.whenData((trips) {
      state = AsyncValue.data(trips.map((t) {
        if (t.id == tripId) return t.copyWith(status: TripStatus.cancelled);
        return t;
      }).toList());
    });
  }
}