import 'package:bvibe/components/navigation.title.dart';
import 'package:bvibe/invoice/invoice.page.dart';
import 'package:flutter/material.dart';

class ViewOrder extends StatelessWidget {
  final String ReceiptId;
  const ViewOrder({super.key, required this.ReceiptId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          NavigationTitle(
            title: "Orders",
            subtitle: "View orders",
            isBtn: true,
            isBackIcon: true,
            btnText: "Print Receipt (Ctrl+P)",
            onTap: () {
              print("again print");
            },
          ),

          const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: InvoicePage.fromId(ReceiptId),
            ),
          ),
        ],
      ),
    );
  }
}
