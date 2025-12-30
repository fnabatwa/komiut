enum PaymentType { topUp, trip, refund }
enum PaymentStatus { pending, success, failed }

class PaymentModel {
  final String id;
  final double amount;
  final PaymentType type;
  final String paymentMethod;
  final PaymentStatus status;
  final DateTime date;
  final String description;
  final String? referenceNumber;
  final String? tripId;

  PaymentModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.paymentMethod,
    required this.status,
    required this.date,
    required this.description,
    this.referenceNumber,
    this.tripId,
  });
}