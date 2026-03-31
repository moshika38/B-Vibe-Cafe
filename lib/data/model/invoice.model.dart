import 'package:bvibe/data/model/receipt.model.dart';

class InvoiceDisplayModel {
  final String invoiceId;
  final DateTime dateTime;
  final String paymentMethod;
  final bool isPaid;
  final String totalAmount;
  final String paidAmount;
  final String balanceAmount;
  final List<InvoiceDisplayItem> items;
  final String orderType;
  final bool isRetail;

  const InvoiceDisplayModel({
    required this.invoiceId,
    required this.dateTime,
    required this.paymentMethod,
    required this.isPaid,
    required this.totalAmount,
    required this.paidAmount,
    required this.balanceAmount,
    required this.items,
    required this.orderType,
    required this.isRetail,
  });

  double get totalDiscount =>
      items.fold(0, (sum, i) => sum + i.discountAmount * (int.tryParse(i.qty) ?? 1));

   
  factory InvoiceDisplayModel.fromReceipt(ReceiptModel r) {
    return InvoiceDisplayModel(
      invoiceId: r.receiptId,
      dateTime: r.receiptDateTime,
      paymentMethod: r.paymentMethod,
      isPaid: r.paymentStatus,
      totalAmount: r.totalAmount,
      paidAmount: r.paidAmount,
      balanceAmount: r.balanceAmount,
      items: r.items.map(InvoiceDisplayItem.fromReceiptItem).toList(),
      orderType: r.orderType,
      isRetail: r.items.isNotEmpty && r.items.every((item) => item.isRetail),
    );
  }
}

class InvoiceDisplayItem {
  final String name;
  final String qty;
  final String price;
  final String? discountLabel;
  final String discount;  

  const InvoiceDisplayItem({
    required this.name,
    required this.qty,
    required this.price,
    required this.discount,
    this.discountLabel,
  });

  bool get hasDiscount => (double.tryParse(discount) ?? 0) > 0;

  double get discountAmount => double.tryParse(discount) ?? 0;

  double get finalPrice => (double.tryParse(price) ?? 0) - discountAmount;

  factory InvoiceDisplayItem.fromReceiptItem(ReceiptItemsModel i) {
    final hasDisc = (double.tryParse(i.discount) ?? 0) > 0;
    return InvoiceDisplayItem(
      name: i.itemName,
      qty: i.qty,
      price: i.price,
      discount: i.discount,
      discountLabel: hasDisc ? 'Discount' : null,
    );
  }
}