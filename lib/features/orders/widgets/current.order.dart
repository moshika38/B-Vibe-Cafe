import 'dart:convert';
import 'package:bvibe/const/print/print.invoice.dart';
import 'package:bvibe/provider/printer.provider.dart';
import 'package:bvibe/components/conform.window.dart';
import 'package:bvibe/const/snack/app.snack.dart';
import 'package:bvibe/const/theme/theme.dart';
import 'package:bvibe/data/workspace/number.format.dart';
import 'package:bvibe/features/orders/widgets/current.order.widget.dart';
import 'package:bvibe/features/orders/widgets/empty.item.dart';
import 'package:bvibe/provider/receipt.provider.dart';
import 'package:bvibe/data/model/receipt.model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CurrentOrder extends StatefulWidget {
  final String receiptId;
  final bool isFocused;
  final int selectedIndex;
  const CurrentOrder({
    super.key,
    required this.receiptId,
    this.isFocused = false,
    this.selectedIndex = 0,
  });

  @override
  State<CurrentOrder> createState() => _CurrentOrderState();
}

class _CurrentOrderState extends State<CurrentOrder> {
  Future<void> _handlePlaceOrder(ReceiptModel receipt) async {
    if (receipt.items.isEmpty) {
      AppSnack.errorSnack(
        context,
        'Please add items to securely place the order!',
      );
      return;
    }

    final printerProvider =
        Provider.of<PrinterProvider>(context, listen: false);
    final receiptProvider =
        Provider.of<ReceiptProvider>(context, listen: false);

    final kitchenItems = receipt.items.where((item) => !item.isRetail).toList();

    if (kitchenItems.isNotEmpty) {
      final currentKitchenJson =
          jsonEncode(kitchenItems.map((e) => e.toMap()).toList());
      final lastKitchenJson =
          jsonEncode(receipt.lastKotItems.map((e) => e.toMap()).toList());

      if (currentKitchenJson != lastKitchenJson) {
        final success = await PrintInvoice.printKOT(
          receipt: receipt,
          printer: printerProvider.secondaryPrinter,
        );
        if (success) {
          await receiptProvider.updateLastKotItems(
            receipt.receiptId,
            kitchenItems,
          );
        }
      }
    }

    if (mounted) {
      context.push('/orders/checkout', extra: receipt.receiptId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Consumer<ReceiptProvider>(
        builder: (context, value, child) => FutureBuilder(
          future: value.getReceipt(widget.receiptId),
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.connectionState == ConnectionState.waiting &&
                !asyncSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final receipt = asyncSnapshot.data;
            if (receipt == null) return const Center(child: EmptyItem());

            return Column(
              children: [
                _buildOrderTypeToggle(receipt, value),
                const SizedBox(height: 10),
                CurrentOrderWidget.tableHeader(context),
                const Divider(color: AppColors.cardBorder, height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: receipt.items.length,
                    itemBuilder: (context, index) {
                      return _buildRowCard(
                        context,
                        index,
                        receipt.items[index].itemName,
                        receipt.items[index].price,
                        receipt.items[index].qty,
                        receipt.items[index].discount,
                        ((double.parse(receipt.items[index].price) -
                                    double.parse(
                                      receipt.items[index].discount,
                                    )) *
                                int.parse(receipt.items[index].qty))
                            .toString(),
                      );
                    },
                  ),
                ),
                const Divider(color: AppColors.cardBorder, height: 16),
                const SizedBox(height: 10),
                _buildCheckOutSection(context, receipt),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderTypeToggle(ReceiptModel receipt, ReceiptProvider provider) {
    bool isTakeaway = receipt.orderType == 'Takeaway';

    return Container(
      width: double.infinity,
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () =>
                  provider.updateOrderType(receipt.receiptId, 'Dine-In'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  gradient: !isTakeaway
                      ? const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isTakeaway ? null : null,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: !isTakeaway
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    "Dine-In",
                    style: TextStyle(
                      color: !isTakeaway
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: () =>
                  provider.updateOrderType(receipt.receiptId, 'Takeaway'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  gradient: isTakeaway
                      ? const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: isTakeaway
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    "Takeaway",
                    style: TextStyle(
                      color: isTakeaway
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowCard(
    BuildContext context,
    int index,
    String item,
    String price,
    String qty,
    String discount,
    String total,
  ) {
    final theme = Theme.of(context).textTheme.labelSmall;
    final bool isSelected = widget.isFocused && index == widget.selectedIndex;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withOpacity(0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? Border(left: BorderSide(color: AppColors.primary, width: 3))
            : null,
      ),
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              item,
              style: theme?.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "${AppNumberFormat.formatNumber(double.tryParse(price) ?? 0)} LKR",
              textAlign: TextAlign.right,
              style: theme,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(qty, textAlign: TextAlign.center, style: theme),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "${AppNumberFormat.formatNumber(double.tryParse(discount) ?? 0)} LKR",
              textAlign: TextAlign.right,
              style: theme,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "${AppNumberFormat.formatNumber(double.tryParse(total) ?? 0)} LKR",
              textAlign: TextAlign.right,
              style: theme?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckOutSection(BuildContext context, ReceiptModel receipt) {
    bool isTakeaway = receipt.orderType == 'Takeaway';
    bool isRetailBill =
        receipt.items.isNotEmpty &&
        receipt.items.every((item) => item.isRetail);
    bool shouldExcludeServiceCharge = isRetailBill || isTakeaway;

    final double grandTotal = double.tryParse(receipt.totalAmount) ?? 0.0;
    final double subTotal = shouldExcludeServiceCharge
        ? grandTotal
        : grandTotal / 1.10;
    final double serviceCharge = grandTotal - subTotal;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildSummaryRow(
          context,
          shouldExcludeServiceCharge ? "Subtotal" : "Subtotal",
          "${AppNumberFormat.formatNumber(subTotal)} LKR",
          AppColors.textSecondary,
        ),
        if (!shouldExcludeServiceCharge) ...[
          const SizedBox(height: 6),
          _buildSummaryRow(
            context,
            "Service Charge (10%)",
            "${AppNumberFormat.formatNumber(serviceCharge)} LKR",
            AppColors.textSecondary,
          ),
        ],
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Net Amount".toUpperCase(),
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              Text(
                "${AppNumberFormat.formatNumber(grandTotal)} LKR",
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Consumer<ReceiptProvider>(
              builder: (context, value, child) => Container(
                height: 43,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextButton(
                  onPressed: () async {
                    final isValid = await showPinDialog(context);
                    if (!mounted) return;
                    if (isValid) {
                      context.go('/orders');
                      value.deleteReceipt(widget.receiptId);
                    }
                  },
                  child: Text(
                    "Delete",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _handlePlaceOrder(receipt),
                child: Text(
                  "Place Order",
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
