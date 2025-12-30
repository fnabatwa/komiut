import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/payment_model.dart';
import '../../data/services/payment_service.dart';

final paymentServiceProvider = Provider<PaymentService>((ref) => PaymentService());

class PaymentStateNotifier extends StateNotifier<AsyncValue<List<PaymentModel>>> {
  final PaymentService _paymentService;
  PaymentStateNotifier(this._paymentService) : super(const AsyncValue.loading());

  Future<void> loadPayments(String userId) async {
    state = const AsyncValue.loading();
    try {
      final payments = await _paymentService.getPaymentHistory(userId);
      state = AsyncValue.data(payments);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<PaymentModel?> topUpWallet({
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      final payment = await _paymentService.topUpWallet(
        amount: amount,
        paymentMethod: paymentMethod,
      );
      if (state is AsyncData<List<PaymentModel>>) {
        state = AsyncValue.data([payment, ...state.value!]);
      }
      return payment;
    } catch (e) {
      return null;
    }
  }
}

final paymentStateProvider = StateNotifierProvider<PaymentStateNotifier, AsyncValue<List<PaymentModel>>>((ref) {
  return PaymentStateNotifier(ref.read(paymentServiceProvider));
});