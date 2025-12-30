import 'dart:async';
import '../../domain/models/payment_model.dart';

class PaymentService {
  final List<PaymentModel> _mockPayments = [
    PaymentModel(
      id: 'pay_001',
      amount: 1000.0,
      type: PaymentType.topUp,
      paymentMethod: 'M-Pesa',
      status: PaymentStatus.success,
      date: DateTime.now().subtract(const Duration(hours: 2)),
      description: 'Wallet Top-up',
      referenceNumber: 'MPESA-REF-1',
    ),
    PaymentModel(
      id: 'pay_002',
      amount: 2500.0,
      type: PaymentType.topUp,
      paymentMethod: 'Visa Card',
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
      type: PaymentType.topUp, // Assuming trip payments also show here
      paymentMethod: 'Wallet',
      status: PaymentStatus.success,
      date: DateTime.now().subtract(const Duration(days: 3)),
      description: 'Trip Booking: Nairobi - Busia',
      referenceNumber: 'TRP-662-NB',
    ),
    PaymentModel(
      id: 'pay_005',
      amount: 3000.0,
      type: PaymentType.topUp,
      paymentMethod: 'MasterCard',
      status: PaymentStatus.success,
      date: DateTime.now().subtract(const Duration(days: 5, hours: 10)),
      description: 'Wallet Top-up',
      referenceNumber: 'CRD-1102-Y',
    ),
    PaymentModel(
      id: 'pay_006',
      amount: 150.0,
      type: PaymentType.topUp,
      paymentMethod: 'M-Pesa',
      status: PaymentStatus.success,
      date: DateTime.now().subtract(const Duration(days: 7)),
      description: 'Wallet Top-up',
      referenceNumber: 'RKT992000L',
    ),
    PaymentModel(
      id: 'pay_007',
      amount: 4500.0,
      type: PaymentType.topUp,
      paymentMethod: 'Visa Card',
      status: PaymentStatus.failed,
      date: DateTime.now().subtract(const Duration(days: 10)),
      description: 'Wallet Top-up',
      referenceNumber: 'AUTH-FAIL-82',
    ),
  ];

  Future<List<PaymentModel>> getPaymentHistory(String userId) async {
    await Future.delayed(const Duration(seconds: 1));
    final sorted = List<PaymentModel>.from(_mockPayments);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  Future<PaymentModel> topUpWallet({
    required double amount,
    required String paymentMethod,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    final payment = PaymentModel(
      id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      type: PaymentType.topUp,
      paymentMethod: paymentMethod,
      status: PaymentStatus.success,
      date: DateTime.now(),
      description: 'Wallet Top-up',
      referenceNumber: 'REF-${DateTime.now().millisecondsSinceEpoch}',
    );
    _mockPayments.insert(0, payment);
    return payment;
  }

  Future<Map<String, dynamic>> getPaymentStatistics(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final success = _mockPayments.where((p) => p.status == PaymentStatus.success);
    final spent = success.where((p) => p.type == PaymentType.trip).fold<double>(0, (s, p) => s + p.amount);
    return {
      'total_spent': spent,
      'total_payments': _mockPayments.length,
    };
  }

  Future<PaymentModel> processTripPayment({
    required double amount,
    required String tripId,
    required String description,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    final payment = PaymentModel(
      id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      type: PaymentType.trip,
      paymentMethod: 'Wallet',
      status: PaymentStatus.success,
      date: DateTime.now(),
      description: description,
      tripId: tripId,
    );
    _mockPayments.insert(0, payment);
    return payment;
  }

  Future<List<PaymentModel>> filterPaymentsByType(String userId, PaymentType type) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockPayments.where((p) => p.type == type).toList();
  }

  Future<PaymentModel?> getPaymentById(String paymentId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _mockPayments.firstWhere((p) => p.id == paymentId);
    } catch (e) { return null; }
  }

  Future<List<PaymentModel>> getRecentPayments(String userId, {int limit = 5}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final sorted = List<PaymentModel>.from(_mockPayments);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(limit).toList();
  }
}