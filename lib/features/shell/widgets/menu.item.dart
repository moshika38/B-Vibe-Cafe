import 'package:bvibe/const/theme/theme.dart';
import 'package:flutter/material.dart';

class MenuItem extends StatefulWidget {
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
  State<MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(!widget.isOrder ? 12 : 8),
              gradient: widget.isActive
                  ? LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.10),
                        AppColors.primary.withOpacity(0.05),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
              color: !widget.isActive && _isHovered
                  ? AppColors.textPrimary.withOpacity(0.03)
                  : null,
            ),
            child: !widget.isOrder
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: widget.isActive
                                ? AppColors.primary.withOpacity(0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Icon(
                            widget.icon,
                            color: widget.isActive
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Text(
                            widget.label,
                            style: theme.textTheme.labelSmall!.copyWith(
                              color: widget.isActive
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: widget.isActive
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              letterSpacing: 0,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                        if (widget.isActive)
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: Icon(
                        widget.icon,
                        color: widget.isActive
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 28,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
