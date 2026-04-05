import 'package:bvibe/components/navigation.title.dart';
import 'package:bvibe/const/theme/theme.dart';
import 'package:bvibe/features/orders/widgets/checkout.order.summary.dart';
import 'package:bvibe/features/orders/widgets/checkout.payment.section.dart';
import 'package:bvibe/features/orders/widgets/empty.item.dart';
import 'package:bvibe/provider/receipt.provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CheckoutPage extends StatefulWidget {
  final String receiptId;
  const CheckoutPage({super.key, required this.receiptId});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  Future<void> _showBillDiscountDialog(
    BuildContext context,
    ReceiptProvider provider,
    String currentDiscount,
  ) async {
    final TextEditingController controller = TextEditingController(
      text: double.tryParse(currentDiscount)?.toStringAsFixed(0) ?? "0",
    );
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.text.length,
    );

    final double? newDiscount = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Bill Discount (LKR)",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            suffixText: 'LKR',
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (val) => Navigator.pop(ctx, double.tryParse(val)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: AppColors.textHint)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, double.tryParse(controller.text)),
            child: const Text("Apply"),
          ),
        ],
      ),
    );

    if (newDiscount != null && newDiscount >= 0) {
      await provider.updateTotalDiscount(
        widget.receiptId,
        newDiscount.toStringAsFixed(2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final receiptProvider = Provider.of<ReceiptProvider>(context, listen: false);

    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent || event is KeyRepeatEvent) {
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            context.pop(); // Go back to Order Screen
            return KeyEventResult.handled;
          }

          if (event.logicalKey == LogicalKeyboardKey.keyD &&
              HardwareKeyboard.instance.isControlPressed) {
            receiptProvider.getReceipt(widget.receiptId).then((receipt) {
              if (receipt != null && mounted) {
                _showBillDiscountDialog(context, receiptProvider, receipt.totalDiscount);
              }
            });
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Container(
        color: AppColors.background,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const NavigationTitle(
                title: "Orders",
                subtitle: "Checkout",
                isBackIcon: true,
              ),

              const SizedBox(height: 20),
              Consumer<ReceiptProvider>(
                builder: (context, value, child) => FutureBuilder(
                  future: value.getReceipt(widget.receiptId),
                  builder: (context, asyncSnapshot) {
                    if (asyncSnapshot.hasData) {
                      final receipt = asyncSnapshot.data;

                      return Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: CheckoutOrderSummary(receipt: receipt!),
                            ),
                            const SizedBox(width: 25),
                            Expanded(
                              flex: 1,
                              child: CheckoutPaymentSection(receipt: receipt),
                            ),
                          ],
                        ),
                      );
                    }
                    return EmptyItem();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
