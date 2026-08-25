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
    final statusColor = receipt.paymentStatus ? const Color(0xFF16A34A) : const Color(0xFFF59E0B);
    final statusText = receipt.paymentStatus ? 'Completed' : 'Pending';
    final itemsCount = receipt.items.length;
    final timeStr = DateFormat('HH:mm').format(receipt.receiptCreateTime);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Symbols.receipt, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order #${receipt.receiptId.substring(receipt.receiptId.length - 4).toUpperCase()}', style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.1,
                  )),
                  const SizedBox(height: 3),
                  Text('$itemsCount items \u2022 $timeStr', style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    color: AppColors.textHint,
                  )),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Text(
              'LKR ${double.tryParse(receipt.totalAmount)?.toStringAsFixed(2) ?? '0.00'}',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
