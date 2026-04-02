import 'package:bvibe/const/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class AppButtons extends StatelessWidget {
  final bool? isNotPrimary;
  final String text;
  final IconData? icon;
  final VoidCallback onTap;
  const AppButtons({
    super.key,
    required this.text,
    this.icon,
    required this.onTap,
    this.isNotPrimary,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isNotPrimary == true
              ? AppColors.background
              : AppColors.primary,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isNotPrimary == true ? Colors.grey : Colors.transparent,
            width: 0.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(
                icon ?? Symbols.add,
                fill: 1,
                color: isNotPrimary == true
                    ? AppColors.textPrimary
                    : AppColors.surface,
                size: 15,
              ),
              SizedBox(width: 5),
              Text(
                text,
                style: theme.textTheme.titleSmall!.copyWith(
                  color: isNotPrimary == true
                      ? AppColors.textPrimary
                      : AppColors.surface,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
