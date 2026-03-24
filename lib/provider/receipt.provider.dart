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
}
