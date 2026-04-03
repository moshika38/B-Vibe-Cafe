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
import 'package:bvibe/provider/analytics.provider.dart';
import 'package:bvibe/features/dashboard/widgets/summary_table.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool _isLoading = true;
  int _activeOrders = 0;
  double _totalRevenue = 0;
  int _totalOrders = 0;
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
      context.read<CategoriesProvider>().fetchCategories();
      context.read<AnalyticsProvider>().loadAnalytics(period: 'Today');
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
      context.read<AnalyticsProvider>().loadAnalytics(period: 'Today');
    }
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;

    final provider = context.read<ReceiptProvider>();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Fetch Today's Receipts for the list
    final todayData = await provider.getReceiptsByDateRange(today, today);

    // Fetch Yesterday for comparison
    final yesterdayData = await provider.getReceiptsByDateRange(
      yesterday,
      yesterday,
    );

    if (!mounted) return;

    setState(() {
      _activeOrders = todayData.where((r) => !r.paymentStatus).length;
      _totalOrders = todayData.length;
      _totalRevenue = todayData.fold(
        0.0,
        (sum, r) => sum + (double.tryParse(r.totalAmount) ?? 0),
      );
      _avgOrder = _totalOrders > 0 ? _totalRevenue / _totalOrders : 0;

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
            Consumer<AnalyticsProvider>(
              builder: (context, analytics, _) {
                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: AnalysisCard(
                        title: 'Revenue Trend',
                        subTitle: 'Last 7 days performance',
                        child: _buildRevenueTrendChart(theme, analytics),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: AnalysisCard(
                        title: 'Service Flow',
                        subTitle: 'Dine-In vs Takeaway',
                        child: _buildOrderTypePie(theme, analytics),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: AnalysisCard(
                        title: 'Categories',
                        subTitle: 'Revenue by category',
                        child: _buildCategoryRevenuePie(theme, analytics),
                      ),
                    ),
                  ],
                );
              },
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
                          child: Consumer<ReceiptProvider>(
                            builder: (context, receiptProvider, _) {
                              return FutureBuilder<List<ReceiptModel>>(
                                future: receiptProvider.getReceiptsByDateRange(
                                  DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                                  DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                                ),
                                builder: (context, snapshot) {
                                  final receipts = snapshot.data ?? [];
                                  if (receipts.isEmpty) {
                                    return const Center(child: Text('No orders yet today'));
                                  }
                                  return ListView.separated(
                                    itemCount: receipts.length > 20 ? 20 : receipts.length,
                                    separatorBuilder: (context, index) => const Divider(),
                                    itemBuilder: (context, index) {
                                      return OrderListItem(receipt: receipts[index]);
                                    },
                                  );
                                },
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
                          child: Consumer<AnalyticsProvider>(
                            builder: (context, analytics, _) {
                              final popular = analytics.topItems;
                              if (popular.isEmpty) {
                                return const Center(child: Text('No sales yet today'));
                              }
                              return ListView.separated(
                                itemCount: popular.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final item = popular[index];
                                  return PopularItem(
                                    name: item['name'],
                                    count: item['qty'].toInt().toString(),
                                    price: item['price'].toString(),
                                  );
                                },
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
            const SizedBox(height: 32),

            // Detailed Summary Below
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Symbols.analytics, color: AppColors.primary, size: 24),
                            const SizedBox(width: 12),
                            Text(
                              'Detailed Business Intelligence',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: AppColors.textPrimary,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Consumer<AnalyticsProvider>(
                          builder: (context, analytics, _) {
                            return FinancialSummaryTable(
                              summary: analytics.summary,
                              title: "Daily Detailed Metrics",
                            );
                          },
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

  Widget _buildRevenueTrendChart(ThemeData theme, AnalyticsProvider analytics) {
    // Generate weekly revenue list from map
    final List<double> weeklyRevenue = List.generate(7, (index) {
      final date = DateTime.now().subtract(Duration(days: 6 - index));
      final key = DateFormat('yyyy-MM-dd').format(date);
      return analytics.revenueByDay[key] ?? 0.0;
    });

    if (weeklyRevenue.every((r) => r == 0)) {
      return const Center(child: Text('Start selling to see business trends'));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: weeklyRevenue.fold(0.0, (max, r) => r > max ? r : max) * 1.2,
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
          topTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= weeklyRevenue.length) {
                  return const SizedBox.shrink();
                }
                final total = weeklyRevenue.fold(0.0, (a, b) => a + b);
                if (total == 0) return const SizedBox.shrink();
                final percent =
                    ((weeklyRevenue[index] / total) * 100).toStringAsFixed(1);
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    '$percent%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              },
              reservedSize: 24,
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final total = weeklyRevenue.fold(0.0, (a, b) => a + b);
              final percent = ((rod.toY / total) * 100).toStringAsFixed(1);
              return BarTooltipItem(
                'LKR ${rod.toY.toStringAsFixed(2)}\n($percent%)',
                theme.textTheme.bodySmall!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        barGroups: List.generate(7, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: weeklyRevenue[index],
                color: AppColors.primary,
                width: 22,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: weeklyRevenue.fold(0.0, (max, r) => r > max ? r : max) *
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

  Widget _buildOrderTypePie(ThemeData theme, AnalyticsProvider analytics) {
    final data = analytics.orderTypeBreakdown;
    final hasData = data.values.any((v) => v > 0);
    if (!hasData) {
      return const Center(
        child: Text('Order flow distribution will appear here'),
      );
    }

    final total = data.values.fold(0.0, (sum, v) => sum + v);

    return PieChart(
      PieChartData(
        sectionsSpace: 4,
        centerSpaceRadius: 50,
        sections: [
          if ((data['Dine-In'] ?? 0) > 0)
            PieChartSectionData(
              value: data['Dine-In'] ?? 0,
              title:
                  '${((data['Dine-In'] ?? 0) / total * 100).toStringAsFixed(1)}%',
              color: Colors.blue,
              radius: 20,
              titleStyle: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontSize: 10,
              ),
              badgeWidget: _buildPieLabel('Dine-In', Colors.blue),
              badgePositionPercentageOffset: 2.2,
            ),
          if ((data['Takeaway'] ?? 0) > 0)
            PieChartSectionData(
              value: data['Takeaway'] ?? 0,
              title:
                  '${((data['Takeaway'] ?? 0) / total * 100).toStringAsFixed(1)}%',
              color: Colors.orange,
              radius: 20,
              titleStyle: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontSize: 10,
              ),
              badgeWidget: _buildPieLabel('Takeaway', Colors.orange),
              badgePositionPercentageOffset: 2.2,
            ),
          if ((data['Retail'] ?? 0) > 0)
            PieChartSectionData(
              value: data['Retail'] ?? 0,
              title:
                  '${((data['Retail'] ?? 0) / total * 100).toStringAsFixed(1)}%',
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

  Widget _buildCategoryRevenuePie(ThemeData theme, AnalyticsProvider analytics) {
    return Consumer<CategoriesProvider>(
      builder: (context, catProvider, _) {
        final allCategories = catProvider.categories;
        final catRevenue = analytics.categoryRevenue;

        if (allCategories.isEmpty) {
          return const Center(child: Text('No categories defined'));
        }

        final total = catRevenue.values.fold(0.0, (sum, v) => sum + v);

        // Map ID to Name and revenue
        final namedRevenue = <String, double>{};
        final catNameMap = {for (var c in allCategories) c.id: c.itemName};
        catRevenue.forEach((id, rev) {
          final name = catNameMap[id] ?? id;
          namedRevenue[name] = (namedRevenue[name] ?? 0) + rev;
        });

        final List<PieChartSectionData> sections = [];
        final List<Widget> legendItems = [];

        final colors = [
          Colors.purple,
          Colors.teal,
          Colors.indigo,
          Colors.pink,
          Colors.orange,
          Colors.blue,
          Colors.green,
          Colors.amber,
          Colors.cyan,
          Colors.deepOrange,
        ];

        int colorIndex = 0;
        namedRevenue.forEach((name, rev) {
          if (rev > 0) {
            final color = colors[colorIndex % colors.length];
            sections.add(
              PieChartSectionData(
                value: rev,
                title: '${(rev / total * 100).toStringAsFixed(1)}%',
                color: color,
                radius: 20,
                titleStyle: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            );
            legendItems.add(_buildPieLabel(name, color));
            colorIndex++;
          }
        });

        if (total == 0 || sections.isEmpty) {
          return const Center(child: Text('No sales by category today'));
        }

        return Column(
          children: [
            Expanded(
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 50,
                  sections: sections,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: legendItems,
            ),
          ],
        );
      },
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
