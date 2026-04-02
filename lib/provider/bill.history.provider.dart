import 'package:bvibe/data/helper/database.helper.dart';
import 'package:bvibe/data/model/receipt.model.dart';
import 'package:flutter/material.dart';

class BillHistoryProvider extends ChangeNotifier {
  List<ReceiptModel> _receipts = [];
  List<ReceiptModel> get receipts => _receipts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Fetch all receipts sorted by newest first
  Future<void> fetchAllReceipts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'receipts',
        orderBy: 'receipt_create_date DESC, receipt_create_time DESC',
      );

      _receipts = maps.map((e) => ReceiptModel.fromMap(e)).toList();
    } catch (e) {
      debugPrint("Error fetching all receipts: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch receipts within a date range (inclusive)
  Future<void> fetchReceiptsByDateRange(DateTime start, DateTime end) async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await DatabaseHelper.instance.database;

      // Normalize dates to ensure full day coverage
      final startDate = DateTime(start.year, start.month, start.day, 0, 0, 0);
      final endDate = DateTime(end.year, end.month, end.day, 23, 59, 59);

      final List<Map<String, dynamic>> maps = await db.query(
        'receipts',
        where: 'receipt_create_date BETWEEN ? AND ?',
        whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
        orderBy: 'receipt_create_date DESC, receipt_create_time DESC',
      );

      _receipts = maps.map((e) => ReceiptModel.fromMap(e)).toList();
    } catch (e) {
      debugPrint("Error fetching receipts by date range: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Insert a new receipt
  Future<void> insertReceipt(ReceiptModel receipt) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.insert('receipts', receipt.toMap());
      await fetchAllReceipts(); // Refresh local state
    } catch (e) {
      debugPrint("Error inserting receipt: $e");
    }
  }

  // Update existing receipt
  Future<void> updateReceipt(ReceiptModel receipt) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'receipts',
        receipt.toMap(),
        where: 'receipt_id = ?',
        whereArgs: [receipt.receiptId],
      );
      await fetchAllReceipts(); // Refresh local state
    } catch (e) {
      debugPrint("Error updating receipt: $e");
    }
  }

  // Delete a receipt
  Future<void> deleteReceipt(String receiptId) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete(
        'receipts',
        where: 'receipt_id = ?',
        whereArgs: [receiptId],
      );
      await fetchAllReceipts(); // Refresh local state
    } catch (e) {
      debugPrint("Error deleting receipt: $e");
    }
  }

  // Search receipts by ID
  Future<void> searchReceipts(String query) async {
    if (query.isEmpty) {
      await fetchAllReceipts();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'receipts',
        where: 'receipt_id LIKE ?',
        whereArgs: ['%$query%'],
        orderBy: 'receipt_create_date DESC, receipt_create_time DESC',
      );

      _receipts = maps.map((e) => ReceiptModel.fromMap(e)).toList();
    } catch (e) {
      debugPrint("Error searching receipts: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}