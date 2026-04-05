import 'dart:convert';

class ExpenseModel {
  final String id;
  final String amount;
  final String date;
  final String description;
  final String? itemId; // Link to expense_items
  final String qty; // Quantity of units

  ExpenseModel({
    required this.id,
    required this.amount,
    required this.date,
    required this.description,
    this.itemId,
    this.qty = '0',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'date': date,
      'description': description,
      'item_id': itemId,
      'qty': qty,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'],
      amount: map['amount'],
      date: map['date'],
      description: map['description'],
      itemId: map['item_id'],
      qty: map['qty'] ?? '0',
    );
  }

  String toJson() => json.encode(toMap());

  factory ExpenseModel.fromJson(String source) =>
      ExpenseModel.fromMap(json.decode(source));
}
