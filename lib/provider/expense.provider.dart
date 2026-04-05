import 'package:bvibe/data/helper/database.helper.dart';
import 'package:bvibe/data/model/expense.model.dart';
import 'package:bvibe/data/model/expense_item.model.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ExpenseProvider extends ChangeNotifier {
  List<ExpenseModel> _expenses = [];
  List<ExpenseModel> get expenses => _expenses;

  List<ExpenseItemModel> _expenseItems = [];
  List<ExpenseItemModel> get expenseItems => _expenseItems;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchExpenseItems() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final maps = await db.query('expense_items', orderBy: 'name ASC');
      _expenseItems = maps.map((e) => ExpenseItemModel.fromMap(e)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching expense items: $e");
    }
  }

  Future<void> addExpenseItem({
    required String name,
    required String unit,
    String description = '',
  }) async {
    final newItem = ExpenseItemModel(
      id: const Uuid().v4(),
      name: name,
      unit: unit,
      description: description,
    );

    try {
      final db = await DatabaseHelper.instance.database;
      await db.insert('expense_items', newItem.toMap());
      _expenseItems.add(newItem);
      _expenseItems.sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding expense item: $e");
      rethrow;
    }
  }

  Future<void> deleteExpenseItem(String id) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete('expense_items', where: 'id = ?', whereArgs: [id]);
      _expenseItems.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting expense item: $e");
      rethrow;
    }
  }

  Future<void> fetchExpensesByDateRange(DateTime start, DateTime end) async {
    _isLoading = true;
    notifyListeners();
    try {
      final db = await DatabaseHelper.instance.database;
      final maps = await db.query(
        'expenses',
        where: 'date BETWEEN ? AND ?',
        whereArgs: [start.toIso8601String(), end.toIso8601String()],
        orderBy: 'date DESC',
      );
      _expenses = maps.map((e) => ExpenseModel.fromMap(e)).toList();
    } catch (e) {
      debugPrint("Error fetching expenses: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExpense({
    required String amount,
    required DateTime date,
    required String description,
    String? itemId,
    String qty = '0',
  }) async {
    final newExpense = ExpenseModel(
      id: const Uuid().v4(),
      amount: amount,
      date: date.toIso8601String(),
      description: description,
      itemId: itemId,
      qty: qty,
    );

    try {
      final db = await DatabaseHelper.instance.database;
      await db.insert('expenses', newExpense.toMap());
      _expenses.insert(0, newExpense);
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding expense: $e");
      rethrow;
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
      _expenses.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting expense: $e");
      rethrow;
    }
  }

  Map<String, double> getTotalsByItem() {
    final totals = <String, double>{};
    for (var exp in _expenses) {
      final name = exp.itemId != null
          ? _expenseItems
              .firstWhere((i) => i.id == exp.itemId,
                  orElse: () => ExpenseItemModel(id: '', name: 'Deleted Item', unit: ''))
              .name
          : 'Miscellaneous';
      final amount = double.tryParse(exp.amount) ?? 0;
      totals[name] = (totals[name] ?? 0) + amount;
    }
    return totals;
  }
}
