import 'package:bvibe/components/navigation.title.dart';
import 'package:bvibe/const/theme/theme.dart';
import 'package:bvibe/features/orders/widgets/checkout.order.summary.dart';
import 'package:bvibe/features/orders/widgets/checkout.payment.section.dart';
import 'package:bvibe/features/orders/widgets/empty.item.dart';
import 'package:bvibe/provider/receipt.provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CheckoutPage extends StatelessWidget {
  final String receiptId;
  const CheckoutPage({super.key, required this.receiptId});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                future: value.getReceipt(receiptId),
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
    );
  }
}
