import 'package:bvibe/const/theme/theme.dart';
import 'package:flutter/material.dart';

class BuildCateCard extends StatefulWidget {
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
  State<BuildCateCard> createState() => _BuildCateCardState();
}

class _BuildCateCardState extends State<BuildCateCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.isActive
                  ? AppColors.primary
                  : (_isHovered
                      ? AppColors.inputBorder
                      : AppColors.cardBorder),
              width: widget.isActive ? 1.5 : 1,
            ),
            color: widget.isActive
                ? AppColors.primarySoft
                : (_isHovered
                    ? AppColors.inputFill
                    : AppColors.surface),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "assets/cate/${widget.icon}.png",
                width: 18,
                height: 18,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.category_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                widget.title,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: widget.isActive
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight: widget.isActive
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
