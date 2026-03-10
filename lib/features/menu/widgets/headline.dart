import 'package:bvibe/const/theme.dart';
import 'package:flutter/material.dart';

class HeadLine extends StatelessWidget {
  const HeadLine({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Categories".toUpperCase(), style: theme.textTheme.labelSmall),
          Text(
            "+ New",
            style: theme.textTheme.labelSmall!.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
