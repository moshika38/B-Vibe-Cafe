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

    return SingleChildScrollView(
      child: Column(
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

          // Recent Orders Section
          _buildSectionHeader(context, "Recent Orders"),
          _buildShortcutsContainer([
            _buildShortcutRow(context, "View Paid Bill", ["Enter"]),
            _buildShortcutRow(context, "Checkout Unpaid Bill", ["Enter"]),
            _buildShortcutRow(context, "Open Order Screen (Unpaid)", ["Ctrl", "Enter"], isLast: true),
          ]),
          const SizedBox(height: 24),

          // Order Create Screen Section
          _buildSectionHeader(context, "Order Create Screen"),
          _buildShortcutsContainer([
            _buildShortcutRow(context, "Change Category", ["Ctrl", "← / →"]),
            _buildShortcutRow(context, "Select Item", ["←", "→"]),
            _buildShortcutRow(context, "Add Item Normally", ["Enter"]),
            _buildShortcutRow(context, "Display/Add Discount", ["Ctrl", "D"]),
            _buildShortcutRow(context, "Close Discount Pop-up", ["Backspace"]),
            _buildShortcutRow(context, "Navigate Back (Recent Orders)", ["Backspace"]),
            _buildShortcutRow(context, "Switch Takeaway/Dine-In", ["Shift", "← / →"]),
            _buildShortcutRow(context, "Delete Item", ["Delete"]),
            _buildShortcutRow(context, "Navigate to Checkout", ["Ctrl", "Enter"], isLast: true),
          ]),
          const SizedBox(height: 24),

          // Checkout Page Section
          _buildSectionHeader(context, "Checkout Page"),
          _buildShortcutsContainer([
            _buildShortcutRow(context, "Change Payment Method", ["Ctrl", "← / →"]),
            _buildShortcutRow(context, "Confirm Payment", ["Enter"]),
            _buildShortcutRow(context, "Print Receipt (If Success)", ["Enter"]),
            _buildShortcutRow(context, "Navigate Back (Order Screen)", ["Backspace"], isLast: true),
          ]),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildShortcutsContainer(List<Widget> children) {
    return Container(
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
          children: children,
        ),
      ),
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
