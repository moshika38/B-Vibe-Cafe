import 'package:bvibe/components/navigation.title.dart';
import 'package:bvibe/const/print/print.invoice.dart';
import 'package:bvibe/invoice/invoice.page.dart';
import 'package:bvibe/provider/business.info.dart';
import 'package:bvibe/provider/printer.provider.dart';
import 'package:bvibe/provider/receipt.provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ViewOrder extends StatelessWidget {
  final String receiptId;
  const ViewOrder({super.key, required this.receiptId});

  @override
  Widget build(BuildContext context) {
    void handlePrint() async {
      final receiptProvider = context.read<ReceiptProvider>();
      final printerProvider = context.read<PrinterProvider>();
      final businessInfo = context.read<BusinessInfoProvider>();

      final receipt = await receiptProvider.getReceipt(receiptId);
      if (receipt != null) {
        PrintInvoice.printReceipt(
          receipt: receipt,
          businessInfo: businessInfo.invoiceData,
          printer: printerProvider.primaryPrinter,
        );
      }
    }

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          final isCtrlPressed =
              HardwareKeyboard.instance.isControlPressed ||
              HardwareKeyboard.instance.isLogicalKeyPressed(
                LogicalKeyboardKey.controlLeft,
              ) ||
              HardwareKeyboard.instance.isLogicalKeyPressed(
                LogicalKeyboardKey.controlRight,
              );

          if (event.logicalKey == LogicalKeyboardKey.backspace ||
              event.logicalKey == LogicalKeyboardKey.escape) {
            context.pop();
            return KeyEventResult.handled;
          }

          if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.keyN) {
            context.push("/orders/newOrder", extra: "");
            return KeyEventResult.handled;
          }

          if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.keyP) {
            handlePrint();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            NavigationTitle(
              title: "Orders",
              subtitle: "View orders",
              isBtn: true,
              isBackIcon: true,
              btnText: "Print Receipt (Ctrl+P)",
              onTap: () => handlePrint(),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: InvoicePage.fromId(receiptId),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
