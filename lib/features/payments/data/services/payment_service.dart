import '../../domain/models/payment_model.dart';

class PaymentService {
  // Mock data to simulate a database
  final List<PaymentModel> _mockPayments = [
    PaymentModel(
      id: 'pay_001',
      amount: 1000.0,
      type: PaymentType.topUp,
      paymentMethod: 'M-Pesa',
      status: PaymentStatus.success,
      date: DateTime.now().subtract(const Duration(hours: 2)),
      description: 'Wallet Top-up',
      referenceNumber: 'QWJ45TR982',
    ),
    PaymentModel(
      id: 'pay_002',
      amount: 2500.0,
      type: PaymentType.topUp,
      paymentMethod: 'Card',
      status: PaymentStatus.success,
      date: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
      description: 'Wallet Top-up',
      referenceNumber: 'CRD-8821-X',
    ),
    PaymentModel(
      id: 'pay_003',
      amount: 500.0,
      type: PaymentType.topUp,
      paymentMethod: 'M-Pesa',
      status: PaymentStatus.failed,
      date: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
      description: 'Wallet Top-up',
      referenceNumber: 'ERR-MPESA-99',
    ),
    PaymentModel(
      id: 'pay_004',
      amount: 1200.0,
      type: PaymentType.trip,
      paymentMethod: 'Wallet',
      status: PaymentStatus.success,
      date: DateTime.now().subtract(const Duration(days: 3)),
      description: 'Trip: Nairobi - Busia',
    ),
  ];

  /// Fetches all transactions for a specific user
  Future<List<PaymentModel>> getPaymentHistory(String userId) async {
    await Future.delayed(const Duration(seconds: 1));
    // Return a copy to ensure UI updates properly
    return List<PaymentModel>.from(_mockPayments);
  }

  Future<PaymentModel> topUpWallet({
    required double amount,
    required String paymentMethod,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    final newPayment = PaymentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      type: PaymentType.topUp,
      paymentMethod: paymentMethod,
      status: PaymentStatus.success,
      date: DateTime.now(),
      description: 'Wallet Top Up via $paymentMethod',
      referenceNumber: 'REF-${DateTime.now().millisecondsSinceEpoch}',
    );

    // Insert at the beginning so it shows at the top of the list
    _mockPayments.insert(0, newPayment);

    return newPayment;
  }
}