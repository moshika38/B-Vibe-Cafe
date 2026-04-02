import 'package:bvibe/const/theme/theme.dart';
import 'package:flutter/material.dart';

class ShortcutKeys extends StatefulWidget {
  const ShortcutKeys({super.key});

  @override
  State<ShortcutKeys> createState() => _ShortcutKeysState();
}

class _ShortcutKeysState extends State<ShortcutKeys> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          "Shortcut Keys",
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "All shortcut keys are listed here",
          style: theme.textTheme.labelSmall,
        ),

        const SizedBox(height: 24),

        // Shortcuts List Container
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: [
                _buildShortcutRow(context, "Search Product", ["Ctrl", "F"]),
                _buildShortcutRow(context, "Select Quantity", ["Shift", "Enter"]),
                _buildShortcutRow(context, "Add Item/Confirm", ["Enter"]),
                _buildShortcutRow(context, "Place Order", ["Numpad Enter"]),
                _buildShortcutRow(context, "Open Payment", ["F2"]),
                _buildShortcutRow(context, "Hold Order", ["F4"]),
                _buildShortcutRow(context, "Cancel/Delete Item", ["Delete"]),
                _buildShortcutRow(context, "Print Receipt", ["Ctrl", "P"], isLast: true),
              ],
            ),
          ),
        ),

        const SizedBox(height: 30),

        // Navigation Shortcuts Section
        Text(
          "Navigation",
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              _buildShortcutRow(context, "Navigate Up", ["↑"]),
              _buildShortcutRow(context, "Navigate Down", ["↓"], isLast: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShortcutRow(
    BuildContext context,
    String action,
    List<String> keys, {
    bool isLast = false,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: AppColors.divider.withValues(alpha: 0.5),
                ),
              ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              action,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Wrap(
            spacing: 6,
            children: keys.map((key) => _buildKey(context, key)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildKey(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 0,
          ),
        ],
      ),
      constraints: const BoxConstraints(minWidth: 32),
      child: Center(
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textPrimary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}
