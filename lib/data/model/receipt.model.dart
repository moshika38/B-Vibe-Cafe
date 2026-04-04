import 'dart:convert';

class ReceiptModel {
  final String receiptId;
  final DateTime receiptCreateDate;
  final DateTime receiptCreateTime;
  final bool paymentStatus;
  final String paymentDate;
  final String paymentTime;
  final String paymentMethod;
  final String totalAmount;
  final String paidAmount;
  final String balanceAmount;
  final String orderType;
  final String totalDiscount;
  final List<ReceiptItemsModel> items;
  final List<ReceiptItemsModel> lastKotItems;

  ReceiptModel({
    required this.receiptId,
    required this.receiptCreateDate,
    required this.receiptCreateTime,
    required this.paymentStatus,
    required this.paymentDate,
    required this.paymentTime,
    required this.paymentMethod,
    required this.totalAmount,
    required this.paidAmount,
    required this.balanceAmount,
    required this.orderType,
    required this.totalDiscount,
    required this.items,
    required this.lastKotItems,
  });

  Map<String, dynamic> toMap() {
    return {
      'receipt_id': receiptId,
      'receipt_create_date': receiptCreateDate.toIso8601String(),
      'receipt_create_time': receiptCreateTime.toIso8601String(),
      'payment_status': paymentStatus ? 1 : 0,
      'payment_date': paymentDate,
      'payment_time': paymentTime,
      'payment_method': paymentMethod,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'balance_amount': balanceAmount,
      'order_type': orderType,
      'total_discount': totalDiscount,
      'items': jsonEncode(items.map((e) => e.toMap()).toList()),
      'last_kot_items': jsonEncode(lastKotItems.map((e) => e.toMap()).toList()),
    };
  }

  factory ReceiptModel.fromMap(Map<String, dynamic> map) {
    return ReceiptModel(
      receiptId: map['receipt_id'],
      receiptCreateDate: DateTime.parse(map['receipt_create_date']),
      receiptCreateTime: DateTime.parse(map['receipt_create_time']),
      paymentStatus: map['payment_status'] == 1,
      paymentDate: map['payment_date'],
      paymentTime: map['payment_time'],
      paymentMethod: map['payment_method'],
      totalAmount: map['total_amount'],
      paidAmount: map['paid_amount'],
      balanceAmount: map['balance_amount'],
      orderType: map['order_type'] ?? 'Dine-In',
      totalDiscount: map['total_discount'] ?? '0.00',
      items: (jsonDecode(map['items']) as List)
          .map((e) => ReceiptItemsModel.fromMap(e))
          .toList(),
      lastKotItems: map['last_kot_items'] == null || map['last_kot_items'] == ""
          ? []
          : (jsonDecode(map['last_kot_items']) as List)
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
  final String discount;
  final bool isRetail;

  ReceiptItemsModel({
    this.id,
    required this.category,
    required this.itemName,
    required this.description,
    required this.price,
    required this.cost,
    required this.imagePath,
    required this.qty,
    required this.discount,
    required this.isRetail,
    
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
      'discount': discount,
      'isRetail': isRetail ? 1 : 0,
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
      discount: map['discount'] ?? '0.00',
      isRetail: map['isRetail'] == 1 || map['isRetail'] == '1' || map['isRetail'] == true,
    );
  }
}
