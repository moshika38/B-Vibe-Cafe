import 'package:bvibe/const/theme/theme.dart';
import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  final bool isActive;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isOrder;
  const MenuItem({
    super.key,
    required this.isActive,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isOrder,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 0.1,
              color: isActive ? AppColors.primary : Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(!isOrder ? 15 : 5),
            color: !isActive
                ? AppColors.surface
                : AppColors.primaryLight.withOpacity(0.15),
          ),
          child: !isOrder
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        color: isActive
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 22,
                      ),
                      SizedBox(width: 10),
                      Text(
                        label,
                        style: theme.textTheme.labelSmall!.copyWith(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: Icon(
                      icon,
                      color: isActive
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: 30,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
