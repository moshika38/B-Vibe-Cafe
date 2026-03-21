import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:bvibe/const/theme.dart';

class PopularItem extends StatelessWidget {
  final int index;

  const PopularItem({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = ['Cappuccino', 'Croissant', 'Espresso', 'Avocado Toast'];
    final sales = ['142', '98', '85', '64'];
    final prices = ['\$4.50', '\$3.50', '\$2.50', '\$8.50'];

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(Symbols.local_cafe, color: AppColors.primary, size: 24),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(items[index], style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              )),
              const SizedBox(height: 4),
              Text('${sales[index]} orders', style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 12,
              )),
            ],
          ),
        ),
        Text(
          prices[index],
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
