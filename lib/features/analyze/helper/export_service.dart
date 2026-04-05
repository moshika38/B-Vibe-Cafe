import 'dart:io';
import 'package:bvibe/provider/analytics.provider.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file_plus/open_file_plus.dart';

class ExportService {
  static Future<String?> exportAnalyticsToExcel(AnalyticsProvider analytics) async {
    try {
      final excel = Excel.createExcel();
      
      // Remove default sheet
      excel.rename('Sheet1', 'Overview');
      final overviewSheet = excel['Overview'];

      // --- Sheet 1: Overview ---
      overviewSheet.appendRow([
        TextCellValue('B-VIBE CAFE ANALYTICS REPORT'),
      ]);
      overviewSheet.appendRow([
        TextCellValue('Period:'),
        TextCellValue(analytics.selectedPeriod),
      ]);
      overviewSheet.appendRow([
        TextCellValue('Export Date:'),
        TextCellValue(DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())),
      ]);
      overviewSheet.appendRow([]); // Empty row
      
      final s = analytics.summary;
      overviewSheet.appendRow([TextCellValue('Metric'), TextCellValue('Value')]);
      overviewSheet.appendRow([TextCellValue('Total Revenue'), DoubleCellValue(s.totalRevenue)]);
      overviewSheet.appendRow([TextCellValue('Total Orders'), IntCellValue(s.totalOrders)]);
      overviewSheet.appendRow([TextCellValue('Avg. Order Value'), DoubleCellValue(s.avgOrderValue)]);
      overviewSheet.appendRow([TextCellValue('Total Expenses'), DoubleCellValue(s.totalExpenses)]);
      overviewSheet.appendRow([TextCellValue('Gross Profit'), DoubleCellValue(s.grossProfit)]);
      overviewSheet.appendRow([TextCellValue('Items Sold'), IntCellValue(s.totalItemsSold)]);
      overviewSheet.appendRow([TextCellValue('Profit Margin'), TextCellValue('${(s.totalRevenue > 0 ? (s.grossProfit / s.totalRevenue * 100) : 0).toStringAsFixed(2)}%')]);

      // --- Sheet 2: Top Items ---
      final itemsSheet = excel['Popular Items'];
      itemsSheet.appendRow([
        TextCellValue('Item Name'),
        TextCellValue('Quantity Sold'),
        TextCellValue('Total Revenue'),
        TextCellValue('Unit Price'),
      ]);

      for (var item in analytics.topItems) {
        itemsSheet.appendRow([
          TextCellValue(item['name'] as String),
          DoubleCellValue(item['qty'] as double),
          DoubleCellValue(item['revenue'] as double),
          TextCellValue(item['price'] as String),
        ]);
      }

      // --- Sheet 3: Daily Trends ---
      final trendsSheet = excel['Daily Trends'];
      trendsSheet.appendRow([
        TextCellValue('Date'),
        TextCellValue('Revenue'),
        TextCellValue('Orders'),
      ]);

      final sortedDates = analytics.revenueByDay.keys.toList()..sort();
      for (var date in sortedDates) {
        trendsSheet.appendRow([
          TextCellValue(date),
          DoubleCellValue(analytics.revenueByDay[date] ?? 0),
          IntCellValue(analytics.orderCountByDay[date] ?? 0),
        ]);
      }

      // --- Sheet 4: Order Distribution ---
      final distSheet = excel['Order Distribution'];
      distSheet.appendRow([TextCellValue('Order Type'), TextCellValue('Count')]);
      analytics.orderTypeBreakdown.forEach((type, count) {
        distSheet.appendRow([TextCellValue(type), DoubleCellValue(count)]);
      });
      distSheet.appendRow([]);
      distSheet.appendRow([TextCellValue('Payment Method'), TextCellValue('Count')]);
      analytics.paymentMethodBreakdown.forEach((method, count) {
        distSheet.appendRow([TextCellValue(method), DoubleCellValue(count)]);
      });

      // Save the file
      final fileBytes = excel.encode();
      if (fileBytes == null) return null;

      final directory = await getDownloadsDirectory();
      if (directory == null) return null;

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'B_Vibe_Report_$timestamp.xlsx';
      final filePath = '${directory.path}/$fileName';
      
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);

      return filePath;
    } catch (e) {
      print('Export error: $e');
      return null;
    }
  }

  static Future<void> openExportedFile(String filePath) async {
    await OpenFile.open(filePath);
  }
}
