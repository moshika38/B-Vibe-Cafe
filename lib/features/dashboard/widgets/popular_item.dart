import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:bvibe/const/theme/theme.dart';

class PopularItem extends StatelessWidget {
  final String name;
  final String count;
  final String price;

  const PopularItem({
    super.key,
    required this.name,
    required this.count,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              Text(name, style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              )),
              const SizedBox(height: 4),
              Text('$count orders', style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 12,
              )),
            ],
          ),
        ),
        Text(
          'LKR $price',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
