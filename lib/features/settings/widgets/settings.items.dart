import 'package:bvibe/const/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class SettingsItems extends StatefulWidget {
  final VoidCallback onTap0;
  final VoidCallback onTap1;
  final VoidCallback onTap2;
  final VoidCallback onTap3;
  final VoidCallback onTap4;
  final VoidCallback onTap5;
  final int selectedItem;
  const SettingsItems({
    super.key,
    required this.onTap0,
    required this.onTap1,
    required this.onTap2,
    required this.onTap3,
    required this.onTap4,
    required this.onTap5,
    required this.selectedItem,
  });

  @override
  State<SettingsItems> createState() => _SettingsItemsState();
}

class _SettingsItemsState extends State<SettingsItems> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "configuration".toUpperCase(),
                  style: theme.textTheme.titleMedium!.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),

                SizedBox(height: 20),

                _buildItemsCard(
                  theme,
                  "Shortcut",
                  Symbols.app_badging,
                  widget.selectedItem == 0,
                  widget.onTap0,
                ),
                _buildItemsCard(
                  theme,
                  "Printer & Hardware",
                  Symbols.print_rounded,
                  widget.selectedItem == 1,
                  widget.onTap1,
                ),
                _buildItemsCard(
                  theme,
                  "Business Info",
                  Symbols.business_center,
                  widget.selectedItem == 2,
                  widget.onTap2,
                ),

                _buildItemsCard(
                  theme,
                  "Help & Supports",
                  Symbols.help,
                  widget.selectedItem == 3,
                  widget.onTap3,
                ),
                _buildItemsCard(
                  theme,
                  "Security",
                  Symbols.security,
                  widget.selectedItem == 4,
                  widget.onTap4,
                ),
                _buildItemsCard(
                  theme,
                  "Backup & Restore",
                  Symbols.backup,
                  widget.selectedItem == 5,
                  widget.onTap5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(
    ThemeData theme,
    String title,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? AppColors.primarySoft : Colors.transparent,
            border: Border.all(
              color: isSelected ? AppColors.primary.withValues(alpha: 0.3) : Colors.transparent,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(
                  fill: 1,
                  icon,
                  size: 18,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.labelSmall!.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
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
