import 'dart:convert';

import 'package:bvibe/data/model/receipt.model.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:bvibe/data/helper/database.helper.dart';

class ReceiptProvider extends ChangeNotifier {
  // Save
  Future<void> saveReceipt(ReceiptModel receipt) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'receipts',
      receipt.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    notifyListeners();
  }

  ReceiptModel? _cachedReceipt;

  ReceiptModel? getCachedReceipt(String id) {
    if (_cachedReceipt?.receiptId == id) return _cachedReceipt;
    return null;
  }

  // Get
  Future<ReceiptModel?> getReceipt(String id) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'receipts',
      where: 'receipt_id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    _cachedReceipt = ReceiptModel.fromMap(maps.first);
    return _cachedReceipt;
  }

  // Get All
  Future<List<ReceiptModel>> getAllReceipts() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('receipts');
    return maps.map((e) => ReceiptModel.fromMap(e)).toList().reversed.toList();
  }

  // delete receipt
  Future<void> deleteReceipt(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('receipts', where: 'receipt_id = ?', whereArgs: [id]);
    if (_cachedReceipt?.receiptId == id) _cachedReceipt = null;
    notifyListeners();
  }

  // Update items only by receipt id
  Future<void> updateReceiptItems(
    String receiptId,
    List<ReceiptItemsModel> updatedItems,
  ) async {
    final db = await DatabaseHelper.instance.database;

    await db.update(
      'receipts',
      {'items': jsonEncode(updatedItems.map((e) => e.toMap()).toList())},
      where: 'receipt_id = ?',
      whereArgs: [receiptId],
    );
    await updateTotalAmount(receiptId);

    notifyListeners();
  }

  Future<void> addOrUpdateItem(
    String receiptId,
    ReceiptItemsModel newItem,
  ) async {
    final receipt = await getReceipt(receiptId);
    if (receipt == null) throw Exception('Receipt not found: $receiptId');

    final existingIndex = receipt.items.indexWhere(
      (item) => item.id == newItem.id,
    );

    List<ReceiptItemsModel> updatedItems;
    final newQty = int.tryParse(newItem.qty) ?? 0;

    if (existingIndex != -1) {
      updatedItems = [...receipt.items];
      if (newQty <= 0) {
        updatedItems.removeAt(existingIndex);
      } else {
        updatedItems[existingIndex] = newItem;
      }
    } else {
      updatedItems = [...receipt.items];
      if (newQty > 0) {
        updatedItems.add(newItem);
      }
    }

    await updateReceiptItems(receiptId, updatedItems);
  }

  Future<void> updateTotalAmount(String receiptId) async {
    final receipt = await getReceipt(receiptId);
    if (receipt == null) return;

    double netTotal = 0;
    for (int i = 0; i < receipt.items.length; i++) {
      double price = double.tryParse(receipt.items[i].price) ?? 0;
      double discount = double.tryParse(receipt.items[i].discount) ?? 0;
      int qty = int.tryParse(receipt.items[i].qty) ?? 0;
      netTotal += (price - discount) * qty;
    }

    bool isRetail = receipt.items.isNotEmpty && receipt.items.every((item) => item.isRetail);
    double serviceCharge = isRetail ? 0 : netTotal * 0.10;
    double grandTotal = netTotal + serviceCharge;

    final db = await DatabaseHelper.instance.database;
    await db.update(
      'receipts',
      {'total_amount': grandTotal.toStringAsFixed(3)},
      where: 'receipt_id = ?',
      whereArgs: [receiptId],
    );

    notifyListeners();
  }

  // check AllItemsRetail
  Future<bool> isAllItemsRetail(String receiptId) async {
  final receipt = await getReceipt(receiptId);
  if (receipt == null || receipt.items.isEmpty) return false;
  return receipt.items.every((item) => item.isRetail);
}

  // Update payment details by receipt id
  Future<void> updatePayment(
    String receiptId, {
    required bool paymentStatus,
    required String paymentDate,
    required String paymentTime,
    required String paymentMethod,
    required String paidAmount,
    required String balanceAmount,
  }) async {
    final db = await DatabaseHelper.instance.database;

    await db.update(
      'receipts',
      {
        'payment_status': paymentStatus ? 1 : 0,
        'payment_date': paymentDate,
        'payment_time': paymentTime,
        'payment_method': paymentMethod,
        'paid_amount': paidAmount,
        'balance_amount': balanceAmount,
      },
      where: 'receipt_id = ?',
      whereArgs: [receiptId],
    );

    notifyListeners();
  }
}
