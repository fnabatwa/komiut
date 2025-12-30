import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/payment_model.dart';
import '../../data/services/payment_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Provides the raw service for database/API calls
final paymentServiceProvider = Provider((ref) => PaymentService());

/// The main provider that the UI watches for the transaction list
final paymentStateProvider = StateNotifierProvider<PaymentNotifier, AsyncValue<List<PaymentModel>>>((ref) {
  final service = ref.watch(paymentServiceProvider);
  // Listen to the user to get the correct ID
  final user = ref.watch(currentUserProvider);

  return PaymentNotifier(service, user?.id);
});

class PaymentNotifier extends StateNotifier<AsyncValue<List<PaymentModel>>> {
  final PaymentService _service;
  final String? _userId;

  PaymentNotifier(this._service, this._userId) : super(const AsyncValue.loading()) {
    if (_userId != null) {
      fetchHistory(_userId!);
    } else {
      state = const AsyncValue.data([]);
    }
  }

  /// Fetches the list from the service
  Future<void> fetchHistory(String userId) async {
    try {
      // Keep existing data visible while loading if we have it
      if (!state.hasValue) state = const AsyncValue.loading();

      final payments = await _service.getPaymentHistory(userId);
      state = AsyncValue.data(payments);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Processes payment and updates the local state immediately
  Future<PaymentModel?> topUpWallet({
    required double amount,
    required String paymentMethod
  }) async {
    try {
      if (_userId == null) return null;

      final payment = await _service.processPayment(
        amount: amount,
        method: paymentMethod,
        userId: _userId!,
      );

      if (payment != null && payment.status == PaymentStatus.success) {
        // CRITICAL: Update the state list locally so the UI refreshes instantly
        state.whenData((currentHistory) {
          state = AsyncValue.data([payment, ...currentHistory]);
        });
      }

      return payment;
    } catch (e) {
      return null;
    }
  }
}