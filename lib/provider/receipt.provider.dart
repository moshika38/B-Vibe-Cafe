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

  // Get
  Future<ReceiptModel?> getReceipt(String id) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'receipts',
      where: 'receipt_id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return ReceiptModel.fromMap(maps.first);
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

  Future<void> addOrIncrementItem(
    String receiptId,
    ReceiptItemsModel newItem,
  ) async {
    final receipt = await getReceipt(receiptId);
    if (receipt == null) throw Exception('Receipt not found: $receiptId');

    final existingIndex = receipt.items.indexWhere(
      (item) => item.id == newItem.id,
    );

    List<ReceiptItemsModel> updatedItems;

    if (existingIndex != -1) {
      final existingItem = receipt.items[existingIndex];
      final newQty = (int.parse(existingItem.qty) + int.parse(newItem.qty))
          .toString();
      final newNetAmount =
          (int.parse(newQty) * double.parse(existingItem.price)).toString();

      updatedItems = [...receipt.items];
      updatedItems[existingIndex] = ReceiptItemsModel(
        id: existingItem.id,

        itemName: existingItem.itemName,
        description: existingItem.description,
        price: existingItem.price,
        cost: existingItem.cost,
        imagePath: existingItem.imagePath,
        qty: newQty,
        netAmount: newNetAmount,
        category: existingItem.category,
      );
    } else {
      updatedItems = [...receipt.items, newItem];
    }

    await updateReceiptItems(receiptId, updatedItems);
  }

  Future<void> updateTotalAmount(String receiptId) async {
    final receipt = await getReceipt(receiptId);
    if (receipt == null) return;

    double total = 0;
    for (int i = 0; i < receipt.items.length; i++) {
      total += double.parse(receipt.items[i].netAmount);
    }

    final db = await DatabaseHelper.instance.database;
    await db.update(
      'receipts',
      {'total_amount': total.toString()},
      where: 'receipt_id = ?',
      whereArgs: [receiptId],
    );

    notifyListeners();
  }
}
