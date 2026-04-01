import 'package:bvibe/const/theme.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class SettingsItems extends StatefulWidget {
  final VoidCallback onTap0;
  final VoidCallback onTap1;
  final VoidCallback onTap2;
  final VoidCallback onTap3;
  final VoidCallback onTap4;
  final int selectedItem;
  const SettingsItems({
    super.key,
    required this.onTap0,
    required this.onTap1,
    required this.onTap2,
    required this.onTap3,
    required this.onTap4,
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
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(200),
            color: isSelected ? AppColors.surface : null,
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppColors.textSecondary.withValues(alpha: 0.1)
                    : Colors.transparent,
                blurRadius: isSelected ? 10 : 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Icon(
                  fill: 1,
                  icon,
                  size: 20,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: theme.textTheme.labelSmall!.copyWith(
                    color: isSelected
                        ? AppColors.primary
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
