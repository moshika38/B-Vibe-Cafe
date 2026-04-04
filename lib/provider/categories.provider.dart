import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:bvibe/data/model/categories.model.dart';
import 'package:bvibe/data/helper/database.helper.dart';

class CategoriesProvider extends ChangeNotifier {
  static final CategoriesProvider instance = CategoriesProvider._init();

  CategoriesProvider._init();

  List<CategoriesModel> categories = [];
  bool isLoadingCategories = false;

  Future<void> fetchCategories() async {
    isLoadingCategories = true;
    notifyListeners();
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('categories', orderBy: 'orderIndex ASC');
    categories = result.map((map) => CategoriesModel.fromMap(map)).toList();
    isLoadingCategories = false;
    notifyListeners();
  }

  // ── CREATE ──
  Future<int> insertCategory(CategoriesModel category) async {
    final db = await DatabaseHelper.instance.database;
    
    // Get max orderIndex
    final List<Map<String, dynamic>> resMax = await db.rawQuery('SELECT MAX(orderIndex) as maxIndex FROM categories');
    int nextIndex = 0;
    if (resMax.isNotEmpty && resMax.first['maxIndex'] != null) {
      nextIndex = (resMax.first['maxIndex'] as int) + 1;
    }

    final categoryWithIndex = CategoriesModel(
      id: category.id,
      itemName: category.itemName,
      iconNumber: category.iconNumber,
      orderIndex: nextIndex,
    );

    final res = await db.insert(
      'categories',
      categoryWithIndex.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await fetchCategories();
    return res;
  }

  // ── READ ALL ──
  Future<List<CategoriesModel>> readAllCategories() async {
    final db = await DatabaseHelper.instance.database;
    // Query all records, ordered by orderIndex
    final result = await db.query('categories', orderBy: 'orderIndex ASC');

    return result.map((map) => CategoriesModel.fromMap(map)).toList();
  }

  // ── READ ONE ──
  Future<CategoriesModel?> getCategory(String id) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('categories', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return CategoriesModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // ── UPDATE ──
  Future<int> updateCategory(CategoriesModel category) async {
    final db = await DatabaseHelper.instance.database;
    return db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  // ── DELETE ──
  Future<int> deleteCategory(String id) async {
    final db = await DatabaseHelper.instance.database;
    final res = await db.delete('categories', where: 'id = ?', whereArgs: [id]);
    await fetchCategories();
    return res;
  }

  // ── REORDER ──
  Future<void> reorderCategory(String id, int newIndex) async {
    final db = await DatabaseHelper.instance.database;
    
    // Get current list
    final List<CategoriesModel> currentItems = await readAllCategories();
    if (currentItems.isEmpty) return;

    final oldIndex = currentItems.indexWhere((c) => c.id == id);
    if (oldIndex == -1 || oldIndex == newIndex) return;

    final movedItem = currentItems.removeAt(oldIndex);
    currentItems.insert(newIndex, movedItem);

    // Update all indices in a transaction
    await db.transaction((txn) async {
      for (int i = 0; i < currentItems.length; i++) {
        await txn.update(
          'categories',
          {'orderIndex': i},
          where: 'id = ?',
          whereArgs: [currentItems[i].id],
        );
      }
    });

    await fetchCategories();
  }
}
