import 'package:bvibe/const/theme/theme.dart';
import 'package:bvibe/provider/analytics.provider.dart';
import 'package:flutter/material.dart';

class FinancialSummaryTable extends StatelessWidget {
  final AnalyticsSummary summary;
  final String title;

  const FinancialSummaryTable({
    super.key,
    required this.summary,
    this.title = 'Financial Metrics Overview',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final metrics = [
      _MetricData('Total Revenue', 'LKR ${summary.totalRevenue.toStringAsFixed(2)}', null),
      _MetricData('Total Orders', summary.totalOrders.toString(), null),
      _MetricData('Avg. Order Value', 'LKR ${summary.avgOrderValue.toStringAsFixed(2)}', null),
      _MetricData('Total Expenses', 'LKR ${summary.totalExpenses.toStringAsFixed(2)}', null),
      _MetricData('Gross Profit', 'LKR ${summary.grossProfit.toStringAsFixed(2)}',
          summary.grossProfit >= 0 ? const Color(0xFF16A34A) : const Color(0xFFDC2626)),
      _MetricData('Items Sold', summary.totalItemsSold.toString(), null),
      _MetricData('Profit Margin', '${summary.profitMargin.toStringAsFixed(2)}%',
          summary.profitMargin >= 0 ? const Color(0xFF16A34A) : const Color(0xFFDC2626)),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Metric',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Value',
                    textAlign: TextAlign.right,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          ...metrics.asMap().entries.map((entry) {
            final index = entry.key;
            final metric = entry.value;
            final isLast = index == metrics.length - 1;
            
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
              decoration: BoxDecoration(
                border: isLast ? null : Border(
                  bottom: BorderSide(color: AppColors.cardBorder, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      metric.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      metric.value,
                      textAlign: TextAlign.right,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: metric.color ?? AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _MetricData {
  final String label;
  final String value;
  final Color? color;

  _MetricData(this.label, this.value, this.color);
}
