import 'package:bvibe/data/helper/database.helper.dart';
import 'package:bvibe/data/model/invoice.data.model.dart';
import 'package:flutter/material.dart';

class BusinessInfoProvider extends ChangeNotifier {
  BusinessInfoModel? _invoiceData;
  BusinessInfoModel? get invoiceData => _invoiceData;

  // Get current invoice settings
  Future<BusinessInfoModel?> getSettings() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'business_info',
      );

      if (maps.isNotEmpty) {
        _invoiceData = BusinessInfoModel.fromJson(maps.first);
        notifyListeners();
        return _invoiceData;
      }
    } catch (e) {
      debugPrint("Error fetching business info: $e");
    }
    return null;
  }

  // Save (Insert or Update) invoice settings
  Future<void> saveSettings(BusinessInfoModel settings) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final existing = await db.query('business_info');

      if (existing.isEmpty) {
        // Create new
        await db.insert('business_info', settings.toJson());
      } else {
        // Update existing (always update the first/only row for settings)
        await db.update(
          'business_info',
          settings.toJson(),
          where: 'id = ?',
          whereArgs: [existing.first['id']],
        );
      }
      // Refresh local data
      await getSettings();
    } catch (e) {
      debugPrint("Error saving business info: $e");
    }
  }
}
