import 'package:bvibe/components/navigation.title.dart';
import 'package:bvibe/invoice/invoice.page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class ViewOrder extends StatelessWidget {
  final String ReceiptId;
  const ViewOrder({super.key, required this.ReceiptId});

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.backspace || event.logicalKey == LogicalKeyboardKey.escape) {
            context.pop();
            return KeyEventResult.handled;
          }
          final isCtrlPressed = HardwareKeyboard.instance.isControlPressed ||
                                HardwareKeyboard.instance.isLogicalKeyPressed(LogicalKeyboardKey.controlLeft) || 
                                HardwareKeyboard.instance.isLogicalKeyPressed(LogicalKeyboardKey.controlRight);
          if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.keyN) {
            context.push("/orders/newOrder", extra: "");
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
      ),
    );
  }
}
