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

    // Filter to get only kitchen items (non-retail)
    final kitchenItems = receipt.items.where((item) => !item.isRetail).toList();

    if (kitchenItems.isNotEmpty) {
      // Comparison logic
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

    // Always navigate to checkout after attempting to print KOT
    if (mounted) {
      context.push('/orders/checkout', extra: receipt.receiptId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(10),
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
                const Divider(),
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
                const Divider(),
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
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () =>
                  provider.updateOrderType(receipt.receiptId, 'Dine-In'),
              child: Container(
                decoration: BoxDecoration(
                  color: !isTakeaway ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    "Dine-In ( Shift+left )",
                    style: TextStyle(
                      color: !isTakeaway
                          ? AppColors.surface
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () =>
                  provider.updateOrderType(receipt.receiptId, 'Takeaway'),
              child: Container(
                decoration: BoxDecoration(
                  color: isTakeaway ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    "Takeaway  ( Shift+right )",
                    style: TextStyle(
                      color: isTakeaway
                          ? AppColors.surface
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
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

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withOpacity(0.12)
            : (index % 2 == 1
                  ? AppColors.divider.withOpacity(0.3)
                  : Colors.transparent),
        border: isSelected
            ? const Border(left: BorderSide(color: AppColors.primary, width: 4))
            : null,
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              item,
              style: theme,
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
              style: theme,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              shouldExcludeServiceCharge
                  ? "Subtotal".toUpperCase()
                  : "Total".toUpperCase(),
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            Text(
              "${AppNumberFormat.formatNumber(subTotal)} LKR",
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        if (!shouldExcludeServiceCharge) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Service Charge (10%)".toUpperCase(),
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                "${AppNumberFormat.formatNumber(serviceCharge)} LKR",
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Net Amount".toUpperCase(),
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            Text(
              "${AppNumberFormat.formatNumber(grandTotal)} LKR",
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),

        SizedBox(height: 20),

        Row(
          children: [
            Consumer<ReceiptProvider>(
              builder: (context, value, child) => Container(
                height: 43,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 1),
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.background,
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
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _handlePlaceOrder(receipt),
                child: Text(
                  "Place Order ( Ctrl+Enter )",
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: AppColors.surface,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
