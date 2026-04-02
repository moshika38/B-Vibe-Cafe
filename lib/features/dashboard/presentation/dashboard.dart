import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:bvibe/const/theme/theme.dart';
import 'package:bvibe/features/dashboard/widgets/stat_card.dart';
import 'package:bvibe/features/dashboard/widgets/order_list_item.dart';
import 'package:bvibe/features/dashboard/widgets/popular_item.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      const Icon(Symbols.calendar_today, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        'Today, ${DateTime.now().day} ${_getMonth(DateTime.now().month)}',
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
                Expanded(child: StatCard(title: 'Total Orders', value: '124', change: '+12%', icon: Symbols.receipt_long, iconColor: Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: StatCard(title: 'Total Revenue', value: '\$1,240.50', change: '+8%', icon: Symbols.payments, iconColor: AppColors.primary)),
                const SizedBox(width: 16),
                Expanded(child: StatCard(title: 'Active Orders', value: '12', change: '-2%', icon: Symbols.pending_actions, iconColor: Colors.orange)),
                const SizedBox(width: 16),
                Expanded(child: StatCard(title: 'Avg. Order', value: '\$10.00', change: '+5%', icon: Symbols.analytics, iconColor: Colors.green)),
              ],
            ),
            const SizedBox(height: 32),
            
            // Main Content Area
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recent Orders Table
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Recent Orders', style: theme.textTheme.titleLarge?.copyWith(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                              )),
                              TextButton(
                                onPressed: () {},
                                child: const Text('View All'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView.separated(
                              itemCount: 5,
                              separatorBuilder: (context, index) => const Divider(),
                              itemBuilder: (context, index) {
                                return OrderListItem(index: index);
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
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Popular Items', style: theme.textTheme.titleLarge?.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                          )),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView.separated(
                              itemCount: 4,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                return PopularItem(index: index);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
