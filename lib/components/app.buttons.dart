import 'package:bvibe/const/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class AppButtons extends StatefulWidget {
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
  State<AppButtons> createState() => _AppButtonsState();
}

class _AppButtonsState extends State<AppButtons> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final bool isSecondary = widget.isNotPrimary == true;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          transform: _isPressed
              ? (Matrix4.identity()..scale(0.97))
              : Matrix4.identity(),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: isSecondary
                ? null
                : LinearGradient(
                    colors: [
                      AppColors.primary,
                      _isHovered
                          ? AppColors.primaryDark
                          : AppColors.primary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: isSecondary
                ? (_isHovered
                    ? AppColors.inputFill
                    : AppColors.background)
                : null,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSecondary
                  ? AppColors.inputBorder
                  : Colors.transparent,
              width: 1,
            ),
            boxShadow: isSecondary
                ? null
                : [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(
                        _isHovered ? 0.3 : 0.15,
                      ),
                      blurRadius: _isHovered ? 10 : 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.icon ?? Symbols.add,
                  fill: 1,
                  color: isSecondary
                      ? AppColors.textSecondary
                      : AppColors.surface,
                  size: 15,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.text,
                  style: theme.textTheme.titleSmall!.copyWith(
                    color: isSecondary
                        ? AppColors.textSecondary
                        : AppColors.surface,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
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
