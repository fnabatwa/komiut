import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/trip_model.dart';
import '../../../auth/data/services/trip_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Provides the instance of TripService
final tripServiceProvider = Provider<TripService>((ref) => TripService());

/// Global provider to handle trip-related state for the UI
final tripStateProvider = StateNotifierProvider<TripStateNotifier, AsyncValue<List<TripModel>>>((ref) {
  return TripStateNotifier(ref.read(tripServiceProvider), ref);
});

/// FutureProvider used for simple fetching logic
final tripListProvider = FutureProvider.family<List<TripModel>, String>((ref, userId) async {
  return await ref.read(tripServiceProvider).getUserTrips(userId);
});

/// Mock Statistics Provider that recalculates whenever trips update
final tripStatisticsProvider = Provider.family<AsyncValue<Map<String, dynamic>>, String>((ref, userId) {
  final tripsAsync = ref.watch(tripStateProvider);
  return tripsAsync.whenData((trips) {
    // We only count spent money for non-cancelled trips
    double totalSpent = trips
        .where((t) => t.status != TripStatus.cancelled)
        .fold(0, (sum, item) => sum + item.fare);

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

  /// Deducts balance and adds a new trip to the history
  Future<void> bookTrip(TripModel trip) async {
    final user = _ref.read(currentUserProvider);

    if (user == null) throw Exception('User not authenticated');

    if (user.walletBalance < trip.fare) {
      throw Exception('Insufficient balance. Please top up your wallet.');
    }

    try {
      // FIXED: Added departureTime and passengers arguments here
      final savedTrip = await _tripService.createTrip(
        routeName: trip.routeName,
        startLocation: trip.startLocation,
        endLocation: trip.endLocation,
        fare: trip.fare,
        departureTime: trip.departureTime,
        passengers: trip.passengers,
      );

      // Deduct from Wallet Balance
      final newBalance = user.walletBalance - trip.fare;
      _ref.read(authStateProvider.notifier).updateWalletBalance(newBalance);

      // Update the list state immediately for a smooth UX
      state.whenData((trips) {
        state = AsyncValue.data([savedTrip, ...trips]);
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Optional: Helper to update status locally (useful for simulation)
  void cancelTrip(String tripId) {
    state.whenData((trips) {
      state = AsyncValue.data(trips.map((t) {
        if (t.id == tripId) return t.copyWith(status: TripStatus.cancelled);
        return t;
      }).toList());
    });
  }
}