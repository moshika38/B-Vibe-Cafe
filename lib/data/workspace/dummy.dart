import 'package:bvibe/data/model/receipt.model.dart';
import 'package:bvibe/data/workspace/datetime.format.dart';

class DummyData {
  static ReceiptModel get dummyReceipt {
    return ReceiptModel(
      receiptId: _generateInvoiceNumber(),
      receiptCreateDate: DateTime.now(),
      receiptCreateTime: DateTime.now(),
      paymentStatus: false,
      paymentDate: DatetimeFormat.date(),
      paymentTime: DatetimeFormat.time(),
      paymentMethod: "Cash",
      totalAmount: "0",
      paidAmount: "0",
      balanceAmount: "0",
      orderType: "Dine-In",
      totalDiscount: "0.00",
      items: [],
      lastKotItems: [],
    );
  }

  static String _generateInvoiceNumber() {
    final now = DateTime.now();
    return "INV ${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}";
  }
}
