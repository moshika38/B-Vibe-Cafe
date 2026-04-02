import 'package:bvibe/data/helper/database.helper.dart';
import 'package:flutter/material.dart';

class SavedPrinter {
  final String name;
  final String address;
  final String type;
  final bool isBle;
  final String? vendorId;
  final String? productId;
  final String role;

  SavedPrinter({
    required this.name,
    required this.address,
    required this.type,
    required this.isBle,
    this.vendorId,
    this.productId,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'type': type,
      'isBle': isBle ? 1 : 0,
      'vendorId': vendorId ?? "",
      'productId': productId ?? "",
      'role': role,
    };
  }

  factory SavedPrinter.fromMap(Map<String, dynamic> map) {
    return SavedPrinter(
      name: map['name'],
      address: map['address'],
      type: map['type'],
      isBle: map['isBle'] == 1,
      vendorId: map['vendorId'],
      productId: map['productId'],
      role: map['role'],
    );
  }
}

class PrinterProvider extends ChangeNotifier {
  SavedPrinter? _primaryPrinter;
  SavedPrinter? _secondaryPrinter;

  SavedPrinter? get primaryPrinter => _primaryPrinter;
  SavedPrinter? get secondaryPrinter => _secondaryPrinter;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  PrinterProvider() {
    loadPrinters();
  }

  Future<void> loadPrinters() async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> maps = await db.query('printers');
      
      _primaryPrinter = null;
      _secondaryPrinter = null;

      for (var map in maps) {
        final printer = SavedPrinter.fromMap(map);
        if (printer.role == 'primary') {
          _primaryPrinter = printer;
        } else if (printer.role == 'secondary') {
          _secondaryPrinter = printer;
        }
      }
    } catch (e) {
      debugPrint("Error loading printers: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> savePrinter({
    required String name,
    required String address,
    required String type,
    required bool isBle,
    String? vendorId,
    String? productId,
    required String role,
  }) async {
    try {
      final db = await DatabaseHelper.instance.database;
      
      final printer = SavedPrinter(
        name: name,
        address: address,
        type: type,
        isBle: isBle,
        vendorId: vendorId,
        productId: productId,
        role: role,
      );

      // Check if role already exists in DB
      final existing = await db.query(
        'printers',
        where: 'role = ?',
        whereArgs: [role],
      );

      if (existing.isNotEmpty) {
        await db.update(
          'printers',
          printer.toMap(),
          where: 'role = ?',
          whereArgs: [role],
        );
      } else {
        await db.insert('printers', printer.toMap());
      }

      await loadPrinters();
    } catch (e) {
      debugPrint("Error saving printer: $e");
    }
  }

  Future<void> removePrinter(String role) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete(
        'printers',
        where: 'role = ?',
        whereArgs: [role],
      );
      await loadPrinters();
    } catch (e) {
      debugPrint("Error removing printer: $e");
    }
  }

  bool isSelected(String address, String name, String role) {
    if (role == 'primary') {
      return _primaryPrinter?.address == address && _primaryPrinter?.name == name;
    } else {
      return _secondaryPrinter?.address == address && _secondaryPrinter?.name == name;
    }
  }
}
