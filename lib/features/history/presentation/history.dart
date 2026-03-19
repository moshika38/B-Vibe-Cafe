import 'package:bvibe/components/invoice.dart';
import 'package:bvibe/features/history/widgets/details.table.dart';
import 'package:bvibe/features/history/widgets/items.cards.dart';
import 'package:bvibe/features/history/widgets/title.bar.dart';
import 'package:flutter/material.dart';

class History extends StatelessWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ItemsCards.header(context),
          TitleBar(),

          SizedBox(height: 20),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
            
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(  child: DetailsTable()),
                ),
                Expanded(
                  child: SizedBox(
                    child: SingleChildScrollView(
                      child: ThermalReceipt(
                        data: ReceiptData(
                          businessName: 'My Shop',
                          businessAddress: '...',
                          businessPhone: '...',
                          items: [
                            ReceiptItem(name: 'Coca Cola', qty: 2, unitPrice: 280),
                            ReceiptItem(name: 'Coca Cola', qty: 2, unitPrice: 280),
                            
                          ],
                          discountAmount: 50,
                          taxRate: 0.08,
                          paymentMethod: 'CASH',
                          amountPaid: 2500,
                          receiptNo: '0001',
                          dateTime: DateTime.now(),
                        ),
                        paperWidth: 302, // 80mm
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
