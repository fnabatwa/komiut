/// PaymentModel - Represents a payment transaction

class PaymentModel {
  // ==================== PROPERTIES ====================

  /// Unique identifier for the payment
  final String id;

  /// Amount of money in the transaction
  final double amount;

  /// Type of payment (top-up, trip, refund)
  final PaymentType type;

  /// Payment method used (M-Pesa, card, cash, etc.)
  final String paymentMethod;

  /// Status of the payment (success, failed, pending)
  final PaymentStatus status;

  /// When the payment was made
  final DateTime date;

  /// Description of the payment (e.g., "Wallet Top-up", "Trip to CBD")
  final String description;

  /// Reference number for the transaction (optional)
  final String? referenceNumber;

  /// Related trip ID if this payment was for a trip (optional)
  final String? tripId;

  // ==================== CONSTRUCTOR ====================
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

  // ==================== FROM JSON ====================
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      // Convert string to PaymentType enum
      type: PaymentType.values.firstWhere(
            (e) => e.toString().split('.').last == json['type'],
        orElse: () => PaymentType.topUp,
      ),
      paymentMethod: json['payment_method'] as String,
      // Convert string to PaymentStatus enum
      status: PaymentStatus.values.firstWhere(
            (e) => e.toString().split('.').last == json['status'],
        orElse: () => PaymentStatus.success,
      ),
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String,
      referenceNumber: json['reference_number'] as String?,
      tripId: json['trip_id'] as String?,
    );
  }

  // ==================== TO JSON ====================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type.toString().split('.').last,
      'payment_method': paymentMethod,
      'status': status.toString().split('.').last,
      'date': date.toIso8601String(),
      'description': description,
      'reference_number': referenceNumber,
      'trip_id': tripId,
    };
  }

  // ==================== COPY WITH ====================
  PaymentModel copyWith({
    String? id,
    double? amount,
    PaymentType? type,
    String? paymentMethod,
    PaymentStatus? status,
    DateTime? date,
    String? description,
    String? referenceNumber,
    String? tripId,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      date: date ?? this.date,
      description: description ?? this.description,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      tripId: tripId ?? this.tripId,
    );
  }

  // ==================== HELPER METHODS ====================

  /// Get formatted amount with currency symbol
  /// Example: "KES 500.00"
  String get formattedAmount {
    return 'KES ${amount.toStringAsFixed(2)}';
  }

  /// Get formatted date (e.g., "Dec 15, 2024")
  String get formattedDate {
    return '${_monthName(date.month)} ${date.day}, ${date.year}';
  }

  /// Get formatted time (e.g., "2:30 PM")
  String get formattedTime {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  /// Check if payment adds money to wallet (true) or deducts (false)
  bool get isCredit {
    return type == PaymentType.topUp || type == PaymentType.refund;
  }

  /// Helper to get month name
  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  @override
  String toString() {
    return 'PaymentModel(id: $id, amount: $amount, type: $type, status: $status)';
  }
}

// ==================== PAYMENT TYPE ENUM ====================
/// Types of payment transactions
enum PaymentType {
  topUp,      // Adding money to wallet
  trip,       // Payment for a trip
  refund,     // Money returned to user
}

// Extension for user-friendly names
extension PaymentTypeExtension on PaymentType {
  String get displayName {
    switch (this) {
      case PaymentType.topUp:
        return 'Top-up';
      case PaymentType.trip:
        return 'Trip Payment';
      case PaymentType.refund:
        return 'Refund';
    }
  }
}

// ==================== PAYMENT STATUS ENUM ====================
/// Status of a payment transaction
enum PaymentStatus {
  success,    // Payment completed successfully
  failed,     // Payment failed
  pending,    // Payment processing
  cancelled,  // Payment cancelled
}

// Extension for user-friendly names and colors
extension PaymentStatusExtension on PaymentStatus {
  String get displayName {
    switch (this) {
      case PaymentStatus.success:
        return 'Success';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Get color hex for status badge
  String get colorHex {
    switch (this) {
      case PaymentStatus.success:
        return '0xFF10B981'; // Green
      case PaymentStatus.failed:
        return '0xFFEF4444'; // Red
      case PaymentStatus.pending:
        return '0xFFF59E0B'; // Orange
      case PaymentStatus.cancelled:
        return '0xFF6B7280'; // Gray
    }
  }
}