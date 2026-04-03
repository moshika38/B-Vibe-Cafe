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
    
    // Define the metrics from the summary
    final metrics = [
      _MetricData('Total Revenue', 'LKR ${summary.totalRevenue.toStringAsFixed(2)}'),
      _MetricData('Total Orders', summary.totalOrders.toString()),
      _MetricData('Avg. Order Value', 'LKR ${summary.avgOrderValue.toStringAsFixed(2)}'),
      _MetricData('Total Cost', 'LKR ${summary.totalCost.toStringAsFixed(2)}'),
      _MetricData('Gross Profit', 'LKR ${summary.grossProfit.toStringAsFixed(2)}'),
      _MetricData('Items Sold', summary.totalItemsSold.toString()),
      _MetricData('Profit Margin', '${summary.profitMargin.toStringAsFixed(2)}%'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
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
          
          // Data Rows
          ...metrics.asMap().entries.map((entry) {
            final index = entry.key;
            final metric = entry.value;
            final isLast = index == metrics.length - 1;
            
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                border: isLast ? null : const Border(
                  bottom: BorderSide(color: AppColors.divider, width: 0.5),
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
                        color: metric.label.contains('Profit') && !metric.value.contains('-') 
                            ? Colors.green.shade700 
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
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

  _MetricData(this.label, this.value);
}
