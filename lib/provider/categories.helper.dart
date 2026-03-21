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
    final result = await db.query('categories', orderBy: 'itemName ASC');
    categories = result.map((map) => CategoriesModel.fromMap(map)).toList();
    isLoadingCategories = false;
    notifyListeners();
  }

  // ── CREATE ──
  Future<int> insertCategory(CategoriesModel category) async {
    final db = await DatabaseHelper.instance.database;
    final res = await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await fetchCategories();
    return res;
  }

  // ── READ ALL ──
  Future<List<CategoriesModel>> readAllCategories() async {
    final db = await DatabaseHelper.instance.database;
    // Query all records, ordered alphabetically by name
    final result = await db.query('categories', orderBy: 'itemName ASC');

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
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
