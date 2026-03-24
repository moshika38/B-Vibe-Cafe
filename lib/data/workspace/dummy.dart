import 'package:bvibe/data/model/receipt.model.dart';
import 'package:bvibe/data/workspace/datetime.format.dart';

class DummyData {
  static ReceiptModel get dummyReceipt {
    return ReceiptModel(
      receiptId: _generateInvoiceNumber(),
      receiptDateTime: DateTime.now(),
      paymentStatus: false,
      paymentDate: DatetimeFormat.date().toString(),
      paymentTime: DatetimeFormat.time().toString(),
      paymentMethod: "Cash",
      totalAmount: "0",
      paidAmount: "0",
      balanceAmount: "0",
      items: [
        ReceiptItemsModel(
          categoryId: "0",
          itemName: "0",
          description: "",
          price: "0",
          cost: "0",
          imagePath: "imagePath",
          qty: "0",
          netAmount: "0",
        ),
      ],
    );
  }

  static String _generateInvoiceNumber() {
    final now = DateTime.now();
    return "INV ${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}";
  }
}
