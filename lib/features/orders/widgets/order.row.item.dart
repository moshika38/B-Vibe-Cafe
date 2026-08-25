import 'package:bvibe/components/conform.window.dart';
import 'package:bvibe/data/workspace/number.format.dart';
import 'package:bvibe/provider/receipt.provider.dart';
import 'package:flutter/material.dart';
import 'package:bvibe/const/theme/theme.dart';
import 'package:provider/provider.dart';

class OrderRowItem extends StatefulWidget {
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
  State<OrderRowItem> createState() => _OrderRowItemState();
}

class _OrderRowItemState extends State<OrderRowItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = widget.status ? const Color(0xFF16A34A) : const Color(0xFFDC2626);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          onDoubleTap: widget.navigateTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            decoration: BoxDecoration(
              color: widget.isSelect
                  ? AppColors.primarySoft
                  : (_isHovered
                      ? AppColors.inputFill.withOpacity(0.5)
                      : Colors.transparent),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.isSelect
                    ? AppColors.primary.withOpacity(0.3)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 250,
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.invoiceNumber,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: Text(
                    "${widget.items} items",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: Text(
                    "${widget.time.year}/${widget.time.month}/${widget.time.day}",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    "${widget.time.hour}:${widget.time.minute.toString().padLeft(2, '0')}",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
                Container(
                  width: 100,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.status ? "Paid" : "Unpaid",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Rs ${AppNumberFormat.formatNumber(double.parse(widget.amount))} ",
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: widget.navigateTap,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryLight,
                                AppColors.primary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                widget.status
                                    ? Icons.visibility
                                    : Icons.payments_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                widget.status ? "View" : "Pay Now",
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Consumer<ReceiptProvider>(
                        builder: (context, value, child) => GestureDetector(
                          onTap: () async {
                            final isValid = await showPinDialog(context);
                            if (isValid) {
                              value.deleteReceipt(widget.invoiceNumber);
                            }
                          },
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),
                              color: AppColors.inputFill,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 12,
                              color: AppColors.textHint,
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
        ),
      ),
    );
  }
}
