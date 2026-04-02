import 'package:bvibe/data/model/receipt.model.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:bvibe/const/theme/theme.dart';
import 'package:intl/intl.dart';

class OrderListItem extends StatelessWidget {
  final ReceiptModel receipt;

  const OrderListItem({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = receipt.paymentStatus ? Colors.green : Colors.orange;
    final statusText = receipt.paymentStatus ? 'Completed' : 'Pending';
    final itemsCount = receipt.items.length;
    final timeStr = DateFormat('HH:mm').format(receipt.receiptCreateTime);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Symbols.receipt, size: 20, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order #${receipt.receiptId.substring(receipt.receiptId.length - 4).toUpperCase()}', style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                )),
                const SizedBox(height: 4),
                Text('$itemsCount items • $timeStr', style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                )),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withOpacity(0.2)),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'LKR ${double.tryParse(receipt.totalAmount)?.toStringAsFixed(2) ?? '0.00'}',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
