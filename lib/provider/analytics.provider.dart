import 'package:bvibe/data/helper/database.helper.dart';
import 'package:bvibe/data/model/receipt.model.dart';
import 'package:flutter/material.dart';

class AnalyticsSummary {
  final double totalRevenue;
  final int totalOrders;
  final double avgOrderValue;
  final double totalCost;
  final double grossProfit;
  final int totalItemsSold;
  final double profitMargin;

  AnalyticsSummary({
    required this.totalRevenue,
    required this.totalOrders,
    required this.avgOrderValue,
    required this.totalCost,
    required this.grossProfit,
    required this.totalItemsSold,
    required this.profitMargin,
  });
}

class AnalyticsProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _selectedPeriod = 'This Month';
  String get selectedPeriod => _selectedPeriod;

  List<ReceiptModel> _receipts = [];

  // --- Computed metrics ---
  AnalyticsSummary _summary = AnalyticsSummary(
    totalRevenue: 0,
    totalOrders: 0,
    avgOrderValue: 0,
    totalCost: 0,
    grossProfit: 0,
    totalItemsSold: 0,
    profitMargin: 0,
  );
  AnalyticsSummary get summary => _summary;

  // revenue per day: { 'YYYY-MM-DD': amount }
  Map<String, double> _revenueByDay = {};
  Map<String, double> get revenueByDay => _revenueByDay;

  // orders per hour: { 0..23: count }
  Map<int, int> _ordersByHour = {};
  Map<int, int> get ordersByHour => _ordersByHour;

  // order type breakdown: { 'Dine-In': count, ... }
  Map<String, double> _orderTypeBreakdown = {};
  Map<String, double> get orderTypeBreakdown => _orderTypeBreakdown;

  // payment method breakdown: { 'Cash': count, ... }
  Map<String, double> _paymentMethodBreakdown = {};
  Map<String, double> get paymentMethodBreakdown => _paymentMethodBreakdown;

  // top items: [ { name, qty, revenue } ]
  List<Map<String, dynamic>> _topItems = [];
  List<Map<String, dynamic>> get topItems => _topItems;

  // category revenue: { categoryName: revenue }
  Map<String, double> _categoryRevenue = {};
  Map<String, double> get categoryRevenue => _categoryRevenue;

  // daily orders count: { 'YYYY-MM-DD': count }
  Map<String, int> _orderCountByDay = {};
  Map<String, int> get orderCountByDay => _orderCountByDay;

  // Comparison period data
  double _prevPeriodRevenue = 0;
  double get prevPeriodRevenue => _prevPeriodRevenue;
  int _prevPeriodOrders = 0;
  int get prevPeriodOrders => _prevPeriodOrders;

  // Unpaid bills
  int _unpaidOrders = 0;
  int get unpaidOrders => _unpaidOrders;
  double _unpaidAmount = 0;
  double get unpaidAmount => _unpaidAmount;

  static const List<String> periods = [
    'Today',
    'Yesterday',
    'Last 7 Days',
    'This Month',
    'Last Month',
    'All Time',
  ];

  Future<void> loadAnalytics({String? period}) async {
    if (period != null) _selectedPeriod = period;
    _isLoading = true;
    notifyListeners();

    try {
      final db = await DatabaseHelper.instance.database;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      DateTimeRange range = _getDateRange(_selectedPeriod, now, today);
      DateTimeRange prevRange = _getPrevDateRange(_selectedPeriod, now, today);

      // Fetch current period
      final maps = await db.query(
        'receipts',
        where: 'receipt_create_date BETWEEN ? AND ?',
        whereArgs: [
          range.start.toIso8601String(),
          range.end.toIso8601String(),
        ],
        orderBy: 'receipt_create_date ASC',
      );
      _receipts = maps.map((e) => ReceiptModel.fromMap(e)).toList();

      // Fetch prev period
      final prevMaps = await db.query(
        'receipts',
        where: 'receipt_create_date BETWEEN ? AND ?',
        whereArgs: [
          prevRange.start.toIso8601String(),
          prevRange.end.toIso8601String(),
        ],
      );
      final prevReceipts =
          prevMaps.map((e) => ReceiptModel.fromMap(e)).toList();

      _compute(_receipts, prevReceipts);
    } catch (e) {
      debugPrint('Analytics load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  DateTimeRange _getDateRange(
      String period, DateTime now, DateTime today) {
    switch (period) {
      case 'Today':
        return DateTimeRange(
          start: today,
          end: DateTime(today.year, today.month, today.day, 23, 59, 59),
        );
      case 'Yesterday':
        final y = today.subtract(const Duration(days: 1));
        return DateTimeRange(
          start: y,
          end: DateTime(y.year, y.month, y.day, 23, 59, 59),
        );
      case 'Last 7 Days':
        return DateTimeRange(
          start: today.subtract(const Duration(days: 6)),
          end: DateTime(today.year, today.month, today.day, 23, 59, 59),
        );
      case 'This Month':
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month, now.day, 23, 59, 59),
        );
      case 'Last Month':
        final firstDayLastMonth = DateTime(now.year, now.month - 1, 1);
        final lastDayLastMonth = DateTime(now.year, now.month, 0, 23, 59, 59);
        return DateTimeRange(
          start: firstDayLastMonth,
          end: lastDayLastMonth,
        );
      case 'All Time':
      default:
        return DateTimeRange(
          start: DateTime(2020, 1, 1),
          end: DateTime(now.year, now.month, now.day, 23, 59, 59),
        );
    }
  }

  DateTimeRange _getPrevDateRange(
      String period, DateTime now, DateTime today) {
    switch (period) {
      case 'Today':
        final y = today.subtract(const Duration(days: 1));
        return DateTimeRange(
          start: y,
          end: DateTime(y.year, y.month, y.day, 23, 59, 59),
        );
      case 'Yesterday':
        final d = today.subtract(const Duration(days: 2));
        return DateTimeRange(
          start: d,
          end: DateTime(d.year, d.month, d.day, 23, 59, 59),
        );
      case 'Last 7 Days':
        final start = today.subtract(const Duration(days: 13));
        final end = today.subtract(const Duration(days: 7));
        return DateTimeRange(
          start: start,
          end: DateTime(end.year, end.month, end.day, 23, 59, 59),
        );
      case 'This Month':
        final firstDayLastMonth = DateTime(now.year, now.month - 1, 1);
        final lastDayLastMonth = DateTime(now.year, now.month, 0, 23, 59, 59);
        return DateTimeRange(
            start: firstDayLastMonth, end: lastDayLastMonth);
      case 'Last Month':
        final firstDay = DateTime(now.year, now.month - 2, 1);
        final lastDay = DateTime(now.year, now.month - 1, 0, 23, 59, 59);
        return DateTimeRange(start: firstDay, end: lastDay);
      default:
        return DateTimeRange(
          start: DateTime(2019, 1, 1),
          end: DateTime(2019, 12, 31),
        );
    }
  }

  void _compute(List<ReceiptModel> receipts, List<ReceiptModel> prev) {
    double revenue = 0;
    double cost = 0;
    int itemsSold = 0;
    _revenueByDay = {};
    _orderCountByDay = {};
    _ordersByHour = {};
    _orderTypeBreakdown = {};
    _paymentMethodBreakdown = {};
    _categoryRevenue = {};
    _unpaidOrders = 0;
    _unpaidAmount = 0;

    final itemMap = <String, Map<String, dynamic>>{};

    for (final r in receipts) {
      final amount = double.tryParse(r.totalAmount) ?? 0;
      revenue += amount;

      // Unpaid
      if (!r.paymentStatus) {
        _unpaidOrders++;
        _unpaidAmount += amount;
      }

      // Revenue by day
      final dayKey =
          '${r.receiptCreateDate.year}-${r.receiptCreateDate.month.toString().padLeft(2, '0')}-${r.receiptCreateDate.day.toString().padLeft(2, '0')}';
      _revenueByDay[dayKey] = (_revenueByDay[dayKey] ?? 0) + amount;
      _orderCountByDay[dayKey] = (_orderCountByDay[dayKey] ?? 0) + 1;

      // By hour
      final hour = r.receiptCreateTime.hour;
      _ordersByHour[hour] = (_ordersByHour[hour] ?? 0) + 1;

      // Order type
      final type = r.orderType.isNotEmpty ? r.orderType : 'Dine-In';
      _orderTypeBreakdown[type] = (_orderTypeBreakdown[type] ?? 0) + 1;

      // Payment method
      final method =
          r.paymentMethod.isNotEmpty ? r.paymentMethod : 'Unknown';
      _paymentMethodBreakdown[method] =
          (_paymentMethodBreakdown[method] ?? 0) + 1;

      // Items
      for (final item in r.items) {
        final qty = double.tryParse(item.qty) ?? 0;
        final price = double.tryParse(item.price) ?? 0;
        final itemCost = double.tryParse(item.cost) ?? 0;
        final itemRevenue = qty * price;
        final itemCostTotal = qty * itemCost;

        cost += itemCostTotal;
        itemsSold += qty.toInt();

        // Category
        final cat = item.category.isNotEmpty ? item.category : 'Uncategorized';
        _categoryRevenue[cat] = (_categoryRevenue[cat] ?? 0) + itemRevenue;

        // Item rank
        if (itemMap.containsKey(item.itemName)) {
          itemMap[item.itemName]!['qty'] =
              (itemMap[item.itemName]!['qty'] as double) + qty;
          itemMap[item.itemName]!['revenue'] =
              (itemMap[item.itemName]!['revenue'] as double) + itemRevenue;
        } else {
          itemMap[item.itemName] = {
            'name': item.itemName,
            'qty': qty,
            'revenue': itemRevenue,
            'price': item.price,
          };
        }
      }
    }

    _topItems = itemMap.values.toList()
      ..sort((a, b) =>
          (b['revenue'] as double).compareTo(a['revenue'] as double));
    if (_topItems.length > 10) _topItems = _topItems.sublist(0, 10);

    _summary = AnalyticsSummary(
      totalRevenue: revenue,
      totalOrders: receipts.length,
      avgOrderValue: receipts.isEmpty ? 0 : revenue / receipts.length,
      totalCost: cost,
      grossProfit: revenue - cost,
      totalItemsSold: itemsSold,
      profitMargin: revenue > 0 ? ((revenue - cost) / revenue) * 100 : 0,
    );

    // Prev period
    _prevPeriodRevenue = prev.fold(
        0.0, (s, r) => s + (double.tryParse(r.totalAmount) ?? 0));
    _prevPeriodOrders = prev.length;
  }

  String changeLabel(double current, double previous) {
    if (previous == 0) return current > 0 ? '+100%' : '0%';
    final change = ((current - previous) / previous) * 100;
    final prefix = change >= 0 ? '+' : '';
    return '$prefix${change.toStringAsFixed(1)}%';
  }

  bool isPositiveChange(double current, double previous) {
    return current >= previous;
  }
}
