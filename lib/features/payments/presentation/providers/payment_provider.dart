import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/payment_model.dart';
import '../../data/services/payment_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Provides the raw service for database/API calls
final paymentServiceProvider = Provider<PaymentService>((ref) => PaymentService());

/// The main provider that the UI watches for the transaction list
final paymentStateProvider = StateNotifierProvider<PaymentNotifier, AsyncValue<List<PaymentModel>>>((ref) {
  final service = ref.watch(paymentServiceProvider);
  // Listen to the user to get the correct ID
  final user = ref.watch(currentUserProvider);

  return PaymentNotifier(service, user?.id, ref);
});

class PaymentNotifier extends StateNotifier<AsyncValue<List<PaymentModel>>> {
  final PaymentService _service;
  final String? _userId;
  final Ref _ref;

  PaymentNotifier(this._service, this._userId, this._ref) : super(const AsyncValue.loading()) {
    if (_userId != null) {
      fetchHistory(_userId);
    } else {
      // If no user, show empty list instead of infinite loading
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
    required String paymentMethod,
  }) async {
    try {
      if (_userId == null) return null;

      final payment = await _service.topUpWallet(
        amount: amount,
        paymentMethod: paymentMethod,
      );

      if (payment.status == PaymentStatus.success) {
        // 1. Update the local history list (Fixes the '!' warning)
        state.whenData((currentHistory) {
          state = AsyncValue.data([payment, ...currentHistory]);
        });

        // 2. Sync the Wallet Balance in the Auth Provider
        final user = _ref.read(currentUserProvider);
        if (user != null) {
          final newBalance = user.walletBalance + amount;
          _ref.read(authStateProvider.notifier).updateWalletBalance(newBalance);
        }
      }

      return payment;
    } catch (e) {
      // In a production app, you might want to log this error
      return null;
    }
  }

  /// Useful for analytics/dashboard stats
  AsyncValue<Map<String, dynamic>> getStatistics() {
    return state.whenData((payments) {
      final successful = payments.where((p) => p.status == PaymentStatus.success);
      final totalTopUps = successful
          .where((p) => p.type == PaymentType.topUp)
          .fold<double>(0, (sum, p) => sum + p.amount);

      return {
        'count': payments.length,
        'total_topup_value': totalTopUps,
      };
    });
  }
}