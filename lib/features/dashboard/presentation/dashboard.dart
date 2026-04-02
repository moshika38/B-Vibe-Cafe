import 'package:bvibe/data/model/receipt.model.dart';
import 'package:bvibe/provider/receipt.provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:bvibe/const/theme/theme.dart';
import 'package:bvibe/features/dashboard/widgets/stat_card.dart';
import 'package:bvibe/features/dashboard/widgets/order_list_item.dart';
import 'package:bvibe/features/dashboard/widgets/popular_item.dart';
import 'package:bvibe/features/dashboard/widgets/analysis_card.dart';
import 'package:provider/provider.dart';
import 'package:bvibe/provider/categories.helper.dart';
import 'package:intl/intl.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool _isLoading = true;
  List<ReceiptModel> _todayReceipts = [];
  List<Map<String, dynamic>> _popularItems = [];
  List<double> _weeklyRevenue = List.filled(7, 0.0);
  Map<String, double> _orderTypeMap = {'Dine-In': 0, 'Takeaway': 0};
  Map<String, double> _categoryRevenue = {};

  double _totalRevenue = 0;
  int _totalOrders = 0;
  int _activeOrders = 0;
  double _avgOrder = 0;

  String _revenueChange = '0%';
  String _ordersChange = '0%';
  String _activeChange = '0%';
  String _avgChange = '0%';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    // Add listener to refresh data when receipts change
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReceiptProvider>().addListener(_onReceiptsChanged);
    });
  }

  @override
  void dispose() {
    try {
      context.read<ReceiptProvider>().removeListener(_onReceiptsChanged);
    } catch (e) {
      // Handle potential provider access issue during dispose
    }
    super.dispose();
  }

  void _onReceiptsChanged() {
    if (mounted) {
      _loadDashboardData();
    }
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;

    // Only set loading on initial load to avoid flickering on updates
    if (_todayReceipts.isEmpty) {
      setState(() => _isLoading = true);
    }

    final provider = context.read<ReceiptProvider>();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Fetch Today's Data
    final todayData = await provider.getReceiptsByDateRange(today, today);

    // Fetch Last 7 Days for Revenue Trend
    final sevenDaysAgo = today.subtract(const Duration(days: 6));
    final weeklyData = await provider.getReceiptsByDateRange(
      sevenDaysAgo,
      today,
    );

    // Fetch Yesterday for comparison
    final yesterdayData = await provider.getReceiptsByDateRange(
      yesterday,
      yesterday,
    );

    if (!mounted) return;

    setState(() {
      _todayReceipts = todayData;

      // ── TODAY STATS ──
      _totalOrders = _todayReceipts.length;
      _totalRevenue = _todayReceipts.fold(
        0.0,
        (sum, r) => sum + (double.tryParse(r.totalAmount) ?? 0),
      );
      _activeOrders = _todayReceipts.where((r) => !r.paymentStatus).length;
      _avgOrder = _totalOrders > 0 ? _totalRevenue / _totalOrders : 0;

      // ── WEEKLY TREND ──
      _weeklyRevenue = List.filled(7, 0.0);
      for (var receipt in weeklyData) {
        final daysAgo = today
            .difference(
              DateTime(
                receipt.receiptCreateDate.year,
                receipt.receiptCreateDate.month,
                receipt.receiptCreateDate.day,
              ),
            )
            .inDays;
        if (daysAgo >= 0 && daysAgo < 7) {
          _weeklyRevenue[6 - daysAgo] +=
              double.tryParse(receipt.totalAmount) ?? 0;
        }
      }

      // ── ORDER TYPE SPLIT ──
      _orderTypeMap = {'Dine-In': 0, 'Takeaway': 0, 'Retail': 0};
      for (var receipt in _todayReceipts) {
        final type = receipt.orderType;
        _orderTypeMap[type] = (_orderTypeMap[type] ?? 0) + 1;
      }

      // ── STAT CHANGES ──
      final yOrders = yesterdayData.length;
      final yRevenue = yesterdayData.fold(
        0.0,
        (sum, r) => sum + (double.tryParse(r.totalAmount) ?? 0),
      );
      final yAvg = yOrders > 0 ? yRevenue / yOrders : 0;

      _ordersChange = _calculateChange(
        _totalOrders.toDouble(),
        yOrders.toDouble(),
      );
      _revenueChange = _calculateChange(_totalRevenue, yRevenue);
      _activeChange = _calculateChange(
        _activeOrders.toDouble(),
        yesterdayData.where((r) => !r.paymentStatus).length.toDouble(),
      );
      _avgChange = _calculateChange(_avgOrder, yAvg.toDouble());

      // ── POPULAR ITEMS & CATEGORY REVENUE ──
      final itemMap = <String, Map<String, dynamic>>{};
      _categoryRevenue = {};

      // Map category ID to name
      final catProvider = context.read<CategoriesProvider>();
      if (catProvider.categories.isEmpty) {
        catProvider.fetchCategories();
      }
      final catNameMap = {
        for (var c in catProvider.categories) c.id: c.itemName,
      };

      for (var receipt in _todayReceipts) {
        for (var item in receipt.items) {
          final qty = double.tryParse(item.qty) ?? 0.0;
          final price = double.tryParse(item.price) ?? 0.0;
          final itemRevenue = qty * price;

          // Item Map for ranking
          if (itemMap.containsKey(item.itemName)) {
            itemMap[item.itemName]!['count'] =
                (itemMap[item.itemName]!['count'] as num).toDouble() + qty;
          } else {
            itemMap[item.itemName] = {
              'name': item.itemName,
              'count': qty,
              'price': item.price,
            };
          }

          // Category Revenue
          final catId = item.category;
          final catName = catNameMap[catId] ?? 'Other';
          _categoryRevenue[catName] =
              (_categoryRevenue[catName] ?? 0) + itemRevenue;
        }
      }

      _popularItems = itemMap.values.toList();
      _popularItems.sort(
        (a, b) => (b['count'] as num).compareTo(a['count'] as num),
      );
      if (_popularItems.length > 5) {
        _popularItems = _popularItems.sublist(0, 5);
      }

      _isLoading = false;
    });
  }

  String _calculateChange(double current, double previous) {
    if (previous == 0) return current > 0 ? '+100%' : '0%';
    final change = ((current - previous) / previous) * 100;
    final prefix = change >= 0 ? '+' : '';
    return '$prefix${change.toStringAsFixed(0)}%';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard Overview',
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Welcome back! Here is your cafe summary for today.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Symbols.calendar_today,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Today, ${DateTime.now().day} ${_getMonth(DateTime.now().month)} ${DateTime.now().year}',
                        style: theme.textTheme.labelLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Stats Row
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Total Orders',
                    value: _totalOrders.toString(),
                    change: _ordersChange,
                    icon: Symbols.receipt_long,
                    iconColor: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    title: 'Total Revenue',
                    value: 'LKR ${_totalRevenue.toStringAsFixed(2)}',
                    change: _revenueChange,
                    icon: Symbols.payments,
                    iconColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    title: 'Pending Payment',
                    value: _activeOrders.toString(),
                    change: _activeChange,
                    icon: Symbols.pending_actions,
                    iconColor: Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    title: 'Avg. Order',
                    value: 'LKR ${_avgOrder.toStringAsFixed(2)}',
                    change: _avgChange,
                    icon: Symbols.analytics,
                    iconColor: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Analytics Row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: AnalysisCard(
                    title: 'Revenue Trend',
                    subTitle: 'Last 7 days performance',
                    child: _buildRevenueTrendChart(theme),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: AnalysisCard(
                    title: 'Service Flow',
                    subTitle: 'Dine-In vs Takeaway',
                    child: _buildOrderTypePie(theme),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: AnalysisCard(
                    title: 'Categories',
                    subTitle: 'Revenue by category',
                    child: _buildCategoryRevenuePie(theme),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Bottom Content
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recent Orders
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 480,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Orders',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: _todayReceipts.isEmpty
                              ? const Center(child: Text('No orders yet today'))
                              : ListView.separated(
                                  itemCount: _todayReceipts.length > 20
                                      ? 20
                                      : _todayReceipts.length,
                                  separatorBuilder: (context, index) =>
                                      const Divider(),
                                  itemBuilder: (context, index) {
                                    return OrderListItem(
                                      receipt: _todayReceipts[index],
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Popular Items
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 480,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Popular Items',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: _popularItems.isEmpty
                              ? const Center(child: Text('No sales yet today'))
                              : ListView.separated(
                                  itemCount: _popularItems.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final item = _popularItems[index];
                                    return PopularItem(
                                      name: item['name'],
                                      count: item['count'].toInt().toString(),
                                      price: item['price'],
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueTrendChart(ThemeData theme) {
    if (_weeklyRevenue.every((r) => r == 0)) {
      return const Center(child: Text('Start selling to see business trends'));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _weeklyRevenue.fold(0.0, (max, r) => r > max ? r : max) * 1.2,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final date = DateTime.now().subtract(
                  Duration(days: 6 - value.toInt()),
                );
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    DateFormat('E').format(date),
                    style: theme.textTheme.bodySmall,
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(7, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: _weeklyRevenue[index],
                color: AppColors.primary,
                width: 22,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY:
                      _weeklyRevenue.fold(0.0, (max, r) => r > max ? r : max) *
                      1.2,
                  color: AppColors.primary.withOpacity(0.05),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildOrderTypePie(ThemeData theme) {
    final hasData = _orderTypeMap.values.any((v) => v > 0);
    if (!hasData) {
      return const Center(
        child: Text('Order flow distribution will appear here'),
      );
    }

    final total = _orderTypeMap.values.fold(0.0, (sum, v) => sum + v);

    return PieChart(
      PieChartData(
        sectionsSpace: 4,
        centerSpaceRadius: 50,
        sections: [
          PieChartSectionData(
            value: _orderTypeMap['Dine-In'] ?? 0,
            title:
                '${((_orderTypeMap['Dine-In'] ?? 0) / total * 100).toStringAsFixed(0)}%',
            color: Colors.blue,
            radius: 20,
            titleStyle: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontSize: 10,
            ),
            badgeWidget: _buildPieLabel('Dine-In', Colors.blue),
            badgePositionPercentageOffset: 2.2,
          ),
          PieChartSectionData(
            value: _orderTypeMap['Takeaway'] ?? 0,
            title:
                '${((_orderTypeMap['Takeaway'] ?? 0) / total * 100).toStringAsFixed(0)}%',
            color: Colors.orange,
            radius: 20,
            titleStyle: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontSize: 10,
            ),
            badgeWidget: _buildPieLabel('Takeaway', Colors.orange),
            badgePositionPercentageOffset: 2.2,
          ),
          if ((_orderTypeMap['Retail'] ?? 0) > 0)
            PieChartSectionData(
              value: _orderTypeMap['Retail'] ?? 0,
              title:
                  '${((_orderTypeMap['Retail'] ?? 0) / total * 100).toStringAsFixed(0)}%',
              color: Colors.green,
              radius: 20,
              titleStyle: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontSize: 10,
              ),
              badgeWidget: _buildPieLabel('Retail', Colors.green),
              badgePositionPercentageOffset: 2.2,
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryRevenuePie(ThemeData theme) {
    if (_categoryRevenue.isEmpty) {
      return const Center(
        child: Text('Category breakdown will appear here after sales'),
      );
    }

    final total = _categoryRevenue.values.fold(0.0, (sum, v) => sum + v);
    final sortedCategories = _categoryRevenue.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Only show top 4 categories in pie, group others
    final topCategories = sortedCategories.take(4).toList();
    final othersRevenue = sortedCategories
        .skip(4)
        .fold(0.0, (sum, e) => sum + e.value);

    final List<PieChartSectionData> sections = [];
    final colors = [
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.grey,
    ];

    for (int i = 0; i < topCategories.length; i++) {
      final entry = topCategories[i];
      sections.add(
        PieChartSectionData(
          value: entry.value,
          title: '${(entry.value / total * 100).toStringAsFixed(0)}%',
          color: colors[i],
          radius: 20,
          titleStyle: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white,
            fontSize: 10,
          ),
          badgeWidget: _buildPieLabel(entry.key, colors[i]),
          badgePositionPercentageOffset: 2.2,
        ),
      );
    }

    if (othersRevenue > 0) {
      sections.add(
        PieChartSectionData(
          value: othersRevenue,
          title: '${(othersRevenue / total * 100).toStringAsFixed(0)}%',
          color: colors.last,
          radius: 20,
          titleStyle: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white,
            fontSize: 10,
          ),
          badgeWidget: _buildPieLabel('Others', colors.last),
          badgePositionPercentageOffset: 2.2,
        ),
      );
    }

    return PieChart(
      PieChartData(sectionsSpace: 4, centerSpaceRadius: 50, sections: sections),
    );
  }

  Widget _buildPieLabel(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
