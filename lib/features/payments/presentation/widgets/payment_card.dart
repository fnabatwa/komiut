import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/payment_model.dart';

class PaymentCard extends StatelessWidget {
  final PaymentModel payment;
  const PaymentCard({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final isTopUp = payment.type == PaymentType.topUp;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (isTopUp ? Colors.green : Colors.blue).withOpacity(0.1),
          child: Icon(isTopUp ? Icons.add : Icons.directions_bus,
              color: isTopUp ? Colors.green : Colors.blue),
        ),
        title: Text(payment.description),
        subtitle: Text(payment.date.toString().substring(0, 16)),
        trailing: Text(
          '${isTopUp ? "+" : "-"} KES ${payment.amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isTopUp ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }
}