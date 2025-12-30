import '../../domain/models/payment_model.dart';

class PaymentService {
  // Mock data to simulate a database
  // this would be stored in a remote database or local SQL table
  final List<PaymentModel> _mockPayments = [
    PaymentModel(
      id: 'p1',
      amount: 50.0,
      type: PaymentType.trip,
      paymentMethod: 'Wallet',
      status: PaymentStatus.success,
      date: DateTime.now().subtract(const Duration(hours: 2)),
      description: 'Trip to Westlands',
    ),
    PaymentModel(
      id: 'p2',
      amount: 1000.0,
      type: PaymentType.topUp,
      paymentMethod: 'M-Pesa',
      status: PaymentStatus.success,
      date: DateTime.now().subtract(const Duration(days: 1)),
      description: 'Wallet Top Up',
    ),
  ];

  /// Fetches all transactions for a specific user
  Future<List<PaymentModel>> getPaymentHistory(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    return _mockPayments;
  }

  /// Processes a new top-up
  Future<PaymentModel> processPayment({
    required double amount,
    required String method,
    required String userId,
  }) async {
    // Simulate network delay (M-Pesa push/Bank validation)
    await Future.delayed(const Duration(seconds: 2));

    final newPayment = PaymentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      type: PaymentType.topUp,
      paymentMethod: method,
      status: PaymentStatus.success,
      date: DateTime.now(),
      description: 'Wallet Top Up via $method',

    );

    // history shows newest first
    _mockPayments.insert(0, newPayment);

    return newPayment;
  }
}