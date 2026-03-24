import 'dart:convert';

class ReceiptModel {
  final String receiptId;
  final DateTime receiptDateTime;
  final bool paymentStatus;
  final String paymentDate;
  final String paymentTime;
  final String paymentMethod;
  final String totalAmount;
  final String paidAmount;
  final String balanceAmount;
  final List<ReceiptItemsModel> items;

  ReceiptModel({
    required this.receiptId,
    required this.receiptDateTime,
    required this.paymentStatus,
    required this.paymentDate,
    required this.paymentTime,
    required this.paymentMethod,
    required this.totalAmount,
    required this.paidAmount,
    required this.balanceAmount,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'receipt_id': receiptId,
      'receipt_date_time': receiptDateTime.toIso8601String(),
      'payment_status': paymentStatus ? 1 : 0,
      'payment_date': paymentDate,
      'payment_time': paymentTime,
      'payment_method': paymentMethod,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'balance_amount': balanceAmount,
      'items': jsonEncode(items.map((e) => e.toMap()).toList()),
    };
  }

  factory ReceiptModel.fromMap(Map<String, dynamic> map) {
    return ReceiptModel(
      receiptId: map['receipt_id'],
      receiptDateTime: DateTime.parse(map['receipt_date_time']),
      paymentStatus: map['payment_status'] == 1,
      paymentDate: map['payment_date'],
      paymentTime: map['payment_time'],
      paymentMethod: map['payment_method'],
      totalAmount: map['total_amount'],
      paidAmount: map['paid_amount'],
      balanceAmount: map['balance_amount'],
      items: (jsonDecode(map['items']) as List)
          .map((e) => ReceiptItemsModel.fromMap(e))
          .toList(),
    );
  }
}

class ReceiptItemsModel {
  final String? id;
  final String category;
  final String itemName;
  final String description;
  final String price;
  final String cost;
  final String imagePath;
  final String qty;
  final String netAmount;

  ReceiptItemsModel({
    this.id,
    required this.category,
    required this.itemName,
    required this.description,
    required this.price,
    required this.cost,
    required this.imagePath,
    required this.qty,
    required this.netAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': category,
      'item_name': itemName,
      'description': description,
      'price': price,
      'cost': cost,
      'image_path': imagePath,
      'qty': qty,
      'net_amount': netAmount,
    };
  }

  factory ReceiptItemsModel.fromMap(Map<String, dynamic> map) {
    return ReceiptItemsModel(
      id: map['id'],
      category: map['category_id'],
      itemName: map['item_name'],
      description: map['description'],
      price: map['price'],
      cost: map['cost'],
      imagePath: map['image_path'],
      qty: map['qty'],
      netAmount: map['net_amount'],
    );
  }
}
