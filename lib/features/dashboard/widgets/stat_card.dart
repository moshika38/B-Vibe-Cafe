import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:bvibe/const/theme/theme.dart';

class StatCard extends StatefulWidget {
  final String title;
  final String value;
  final String change;
  final IconData icon;
  final Color iconColor;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
    required this.iconColor,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = widget.change.startsWith('+');

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _isHovered
                ? widget.iconColor.withOpacity(0.2)
                : AppColors.cardBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? widget.iconColor.withOpacity(0.06)
                  : Colors.black.withOpacity(0.03),
              blurRadius: _isHovered ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.iconColor.withOpacity(0.10),
                        widget.iconColor.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(widget.icon, color: widget.iconColor, size: 22),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? const Color(0xFFDCFCE7).withOpacity(0.8)
                        : const Color(0xFFFEE2E2).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive
                            ? Symbols.trending_up
                            : Symbols.trending_down,
                        size: 13,
                        color:
                            isPositive ? const Color(0xFF16A34A) : Colors.red,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        widget.change,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: isPositive
                              ? const Color(0xFF16A34A)
                              : Colors.red,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              widget.value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 24,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
