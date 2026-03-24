import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:bvibe/data/model/item.model.dart';
import 'package:bvibe/data/helper/database.helper.dart';

class ItemProvider extends ChangeNotifier {
  static final ItemProvider instance = ItemProvider._init();
  ItemProvider._init();

  List<ItemModel> items = [];
  bool isLoadingItems = false;
  ItemModel? selectedItem;

  void selectItem(ItemModel? item) {
    selectedItem = item;
    notifyListeners();
  }

  Future<void> fetchItems() async {
    isLoadingItems = true;
    notifyListeners();
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('items', orderBy: 'name ASC');
    items = result.map((map) => ItemModel.fromMap(map)).toList();
    isLoadingItems = false;
    notifyListeners();
  }

  // ── CREATE ──
  Future<int> insertItem(ItemModel item) async {
    final db = await DatabaseHelper.instance.database;
    final String itemId =
        item.id ?? DateTime.now().millisecondsSinceEpoch.toString();

    final itemToSave = ItemModel(
      id: itemId,
      categoryId: item.categoryId,
      itemName: item.itemName,
      description: item.description,
      price: double.parse(item.price).toStringAsFixed(2),
cost: double.parse(item.cost).toStringAsFixed(2),
      imagePath: item.imagePath,
    );

    final res = await db.insert(
      'items',
      itemToSave.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await fetchItems();
    return res;
  }

  // ── READ ALL BY CATEGORY ──
  Future<List<ItemModel>> readAllItems(String categoryId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'items',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
      orderBy: 'name ASC',
    );
    return result.map((map) => ItemModel.fromMap(map)).toList();
  }

  // ── READ ONE ──
  Future<ItemModel?> getItem(String id) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('items', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return ItemModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // ── UPDATE ──
  Future<int> updateItem(ItemModel item) async {
    final db = await DatabaseHelper.instance.database;
    final res = await db.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );

    if (selectedItem?.id == item.id) {
      selectedItem = item;
    }

    await fetchItems();
    return res;
  }

  // ── DELETE ──
  Future<int> deleteItem(String id) async {
    final db = await DatabaseHelper.instance.database;
    final res = await db.delete('items', where: 'id = ?', whereArgs: [id]);

    if (selectedItem?.id == id) {
      selectedItem = null;
    }

    await fetchItems();
    return res;
  }
}
