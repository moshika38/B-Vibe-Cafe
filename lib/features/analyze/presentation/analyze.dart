import 'package:bvibe/const/theme/theme.dart';
import 'package:bvibe/features/analyze/widgets/analytics_card.dart';
import 'package:bvibe/features/analyze/widgets/charts.dart';
import 'package:bvibe/features/analyze/widgets/kpi_card.dart';
import 'package:bvibe/provider/analytics.provider.dart';
import 'package:bvibe/provider/categories.helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class AnalyzeScreen extends StatefulWidget {
  const AnalyzeScreen({super.key});

  @override
  State<AnalyzeScreen> createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().loadAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsProvider>(
      builder: (context, analytics, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: analytics.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                )
              : _buildContent(context, analytics),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, AnalyticsProvider analytics) {
    final theme = Theme.of(context);
    final s = analytics.summary;
    final now = DateTime.now();
    final revenueChange = analytics.changeLabel(
        s.totalRevenue, analytics.prevPeriodRevenue);
    final ordersChange = analytics.changeLabel(
        s.totalOrders.toDouble(), analytics.prevPeriodOrders.toDouble());
    final isRevenueUp = analytics.isPositiveChange(
        s.totalRevenue, analytics.prevPeriodRevenue);
    final isOrdersUp = analytics.isPositiveChange(
        s.totalOrders.toDouble(), analytics.prevPeriodOrders.toDouble());

    // Build category revenue with names from provider
    final catProvider = context.read<CategoriesProvider>();
    final catNameMap = {for (var c in catProvider.categories) c.id: c.itemName};
    final namedCatRevenue = <String, double>{};
    analytics.categoryRevenue.forEach((id, rev) {
      final name = catNameMap[id] ?? id;
      namedCatRevenue[name] = (namedCatRevenue[name] ?? 0) + rev;
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          _buildHeader(theme, analytics, now),
          const SizedBox(height: 28),

          // ── KPI Cards ──
          _buildKpiRow(analytics, s, revenueChange, ordersChange,
              isRevenueUp, isOrdersUp),
          const SizedBox(height: 24),

          // ── Alert Banner (if unpaid orders) ──
          if (analytics.unpaidOrders > 0) ...[
            _buildUnpaidBanner(analytics),
            const SizedBox(height: 24),
          ],

          // ── Revenue Trend + Order Type ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: AnalyticsCard(
                  title: 'Revenue Trend',
                  subTitle: 'Sales performance over time',
                  height: 280,
                  child: RevenueTrendChart(
                    revenueByDay: analytics.revenueByDay,
                    period: analytics.selectedPeriod,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: AnalyticsCard(
                  title: 'Service Type',
                  subTitle: 'Order distribution',
                  height: 280,
                  child: OrderTypePieChart(
                    data: analytics.orderTypeBreakdown,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Peak Hours + Payment Methods ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: AnalyticsCard(
                  title: 'Peak Hours',
                  subTitle: 'Orders by hour of day',
                  height: 240,
                  child: OrdersHeatmapChart(
                    ordersByHour: analytics.ordersByHour,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: AnalyticsCard(
                  title: 'Payment Methods',
                  subTitle: 'How customers pay',
                  height: 240,
                  child: PaymentMethodChart(
                    data: analytics.paymentMethodBreakdown,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Top Items + Profit Breakdown ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _buildTopItemsCard(analytics),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: AnalyticsCard(
                  title: 'Profit Breakdown',
                  subTitle: 'Revenue vs Cost vs Profit',
                  height: 340,
                  child: ProfitBreakdownChart(
                    revenue: s.totalRevenue,
                    cost: s.totalCost,
                    profit: s.grossProfit,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Category Revenue ──
          _buildCategoryRevenueCard(namedCatRevenue, analytics),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader(
      ThemeData theme, AnalyticsProvider analytics, DateTime now) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Symbols.analytics,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Analytics & Reports',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 42),
              child: Text(
                'Business intelligence for ${analytics.selectedPeriod}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  const Icon(Symbols.calendar_today,
                      size: 15, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('dd MMM yyyy').format(now),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _buildPeriodSelector(analytics),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodSelector(AnalyticsProvider analytics) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: AnalyticsProvider.periods.map((period) {
          final isSelected = analytics.selectedPeriod == period;
          return GestureDetector(
            onTap: () => analytics.loadAnalytics(period: period),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                period,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKpiRow(
      AnalyticsProvider analytics,
      AnalyticsSummary s,
      String revenueChange,
      String ordersChange,
      bool isRevenueUp,
      bool isOrdersUp) {
    return Row(
      children: [
        Expanded(
          child: KpiCard(
            title: 'Total Revenue',
            value: 'LKR ${s.totalRevenue.toStringAsFixed(2)}',
            change: revenueChange,
            isPositive: isRevenueUp,
            icon: Symbols.payments,
            iconColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: KpiCard(
            title: 'Total Orders',
            value: s.totalOrders.toString(),
            change: ordersChange,
            isPositive: isOrdersUp,
            icon: Symbols.receipt_long,
            iconColor: const Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: KpiCard(
            title: 'Avg. Order Value',
            value: 'LKR ${s.avgOrderValue.toStringAsFixed(2)}',
            change: '—',
            isPositive: true,
            icon: Symbols.analytics,
            iconColor: const Color(0xFF8B5CF6),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: KpiCard(
            title: 'Items Sold',
            value: s.totalItemsSold.toString(),
            change: '—',
            isPositive: true,
            icon: Symbols.shopping_bag,
            iconColor: const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: KpiCard(
            title: 'Gross Profit',
            value: 'LKR ${s.grossProfit.toStringAsFixed(2)}',
            change: s.totalRevenue > 0
                ? '${(s.grossProfit / s.totalRevenue * 100).toStringAsFixed(0)}% margin'
                : '—',
            isPositive: s.grossProfit >= 0,
            icon: Symbols.trending_up,
            iconColor: s.grossProfit >= 0
                ? const Color(0xFF10B981)
                : const Color(0xFFEF4444),
          ),
        ),
      ],
    );
  }

  Widget _buildUnpaidBanner(AnalyticsProvider analytics) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        children: [
          const Icon(Symbols.warning_rounded,
              color: Color(0xFFF59E0B), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textPrimary),
                children: [
                  TextSpan(
                    text:
                        '${analytics.unpaidOrders} unpaid order${analytics.unpaidOrders > 1 ? 's' : ''} ',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text:
                        'totaling LKR ${analytics.unpaidAmount.toStringAsFixed(2)} are pending payment in this period.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopItemsCard(AnalyticsProvider analytics) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 340),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Top Selling Items',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Ranked by revenue',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Top ${analytics.topItems.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TopItemsChart(items: analytics.topItems),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRevenueCard(
      Map<String, double> namedCatRevenue, AnalyticsProvider analytics) {
    final sorted = namedCatRevenue.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = sorted.fold(0.0, (s, e) => s + e.value);

    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFF8B5CF6),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF06B6D4),
      const Color(0xFFEC4899),
      const Color(0xFF84CC16),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Revenue by Category',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Breakdown of sales across all menu categories',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          if (sorted.isEmpty || total == 0)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No category data for this period',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stacked bar
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          height: 28,
                          child: Row(
                            children: List.generate(sorted.length, (i) {
                              final pct = sorted[i].value / total;
                              return Expanded(
                                flex: (pct * 1000).round(),
                                child: Container(
                                  color: colors[i % colors.length],
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...List.generate(sorted.length, (i) {
                        final rev = sorted[i].value;
                        final pct = total > 0 ? (rev / total * 100) : 0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: colors[i % colors.length],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  sorted[i].key,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${pct.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 110,
                                child: Text(
                                  'LKR ${rev.toStringAsFixed(2)}',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: colors[i % colors.length],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                // Summary stats
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _catSummaryTile(
                        'Best Category',
                        sorted.isNotEmpty ? sorted.first.key : '—',
                        Symbols.star_rounded,
                        const Color(0xFFFFD700),
                      ),
                      const SizedBox(height: 12),
                      _catSummaryTile(
                        'Total Categories',
                        '${sorted.length} active',
                        Symbols.category,
                        const Color(0xFF8B5CF6),
                      ),
                      const SizedBox(height: 12),
                      _catSummaryTile(
                        'Category Revenue',
                        'LKR ${total.toStringAsFixed(2)}',
                        Symbols.payments,
                        AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _catSummaryTile(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
