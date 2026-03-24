import 'package:bvibe/const/theme.dart';
import 'package:flutter/material.dart';

class BuildCateCard extends StatelessWidget {
  final bool isActive;
  final String title;
  final int icon;
  final VoidCallback onTap;
  const BuildCateCard({
    super.key,
    required this.isActive,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: SizedBox(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.surface,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              children: [
                Image.asset("assets/cate/$icon.png", width: 20,height: 20,),
                const SizedBox(width: 5),
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isActive
                        ? AppColors.surface
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
