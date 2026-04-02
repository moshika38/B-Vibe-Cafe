import 'package:bvibe/const/theme/theme.dart';
import 'package:flutter/material.dart';

class HeadLine extends StatelessWidget {
  final VoidCallback onTap;
  const HeadLine({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Categories".toUpperCase(), style: theme.textTheme.labelSmall),
          GestureDetector(
            onTap: onTap,
            child: Text(
              "+ New",
              style: theme.textTheme.labelSmall!.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
