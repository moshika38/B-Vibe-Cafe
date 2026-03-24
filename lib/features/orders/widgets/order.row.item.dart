import 'package:bvibe/components/conform.window.dart';
import 'package:bvibe/provider/receipt.provider.dart';
import 'package:flutter/material.dart';
import 'package:bvibe/const/theme.dart';
import 'package:provider/provider.dart';

class OrderRowItem extends StatelessWidget {
  final int index;
  final String invoiceNumber;
  final String items;
  final DateTime time;
  final String amount;
  final bool status;
  final bool isSelect;
  final VoidCallback onTap;
  final VoidCallback navigateTap;

  const OrderRowItem({
    super.key,
    required this.index,
    required this.isSelect,
    required this.onTap,
    required this.navigateTap,
    required this.invoiceNumber,
    required this.items,
    required this.time,
    required this.amount,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = status ? Colors.green : Colors.redAccent;

    return GestureDetector(
      onTap: onTap,
      onDoubleTap: navigateTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: index.isEven
              ? Colors.transparent
              : AppColors.inputFill.withOpacity(0.4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelect ? AppColors.primary : Colors.transparent,
            width: isSelect ? 1 : 0,
          ),
        ),
        child: Row(
          children: [
            // Order ID
            SizedBox(
              width: 250,
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primaryLight,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      size: 12,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    invoiceNumber,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            // Items count
            SizedBox(
              width: 150,
              child: Text(
                "${items}of items",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            // Date
            SizedBox(
              width: 150,
              child: Text(
                "${time.year}/${time.month}/${time.day}",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
            // Time
            SizedBox(
              width: 100,
              child: Text(
                "${time.hour}:${time.minute}",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),

            // Status badge
            Container(
              width: 100,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor.withOpacity(0.25)),
              ),
              child: Text(
                status ? "Paid" : "Unpaid",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Amount
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Rs $amount",

                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(width: 15),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      color: AppColors.primaryLight,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: AppColors.background,
                    ),
                  ),
                  SizedBox(width: 15),
                  Consumer<ReceiptProvider>(
                    builder: (context, value, child) => GestureDetector(
                      onTap: () async {
                        final isValid = await showPinDialog(context);
                        if (isValid) {
                          value.deleteReceipt(invoiceNumber);
                        }
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          color: AppColors.primaryLight,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 12,
                          color: AppColors.background,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
