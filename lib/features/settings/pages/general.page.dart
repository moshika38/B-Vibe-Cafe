import 'package:bvibe/const/theme.dart';
import 'package:bvibe/features/settings/widgets/key.preview.dart';
import 'package:bvibe/data/workspace/number.format.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class GeneralPage extends StatefulWidget {
  const GeneralPage({super.key});

  @override
  State<GeneralPage> createState() => _GeneralPageState();
}

class _GeneralPageState extends State<GeneralPage> {
  // Receipt Settings State
  final TextEditingController _shopNameController = TextEditingController(
    text: "My Shop",
  );
  final TextEditingController _addressController = TextEditingController(
    text: "123 Main Street, Colombo",
  );
  final TextEditingController _phoneController = TextEditingController(
    text: "+94 11 234 5678",
  );
  final TextEditingController _footerController = TextEditingController(
    text: "Thank you for your purchase!",
  );

  @override
  void dispose() {
    _shopNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          "General Settings",
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Manage regional settings and appearance preferences.",
          style: theme.textTheme.labelSmall,
        ),

        const SizedBox(height: 30),

        // Main Content
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left - Settings Form
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(theme, "Receipt Settings"),
                  const SizedBox(height: 16),
                  _buildTextField(
                    theme,
                    "Shop Name",
                    _shopNameController,
                    Symbols.store,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    theme,
                    "Address",
                    _addressController,
                    Symbols.location_on,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    theme,
                    "Phone",
                    _phoneController,
                    Symbols.phone,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    theme,
                    "Footer Message",
                    _footerController,
                    Symbols.notes,
                  ),
                  const SizedBox(height: 24),

                  KeyPreview(),
                ],
              ),
            ),

            const SizedBox(width: 30),

            // Right - Receipt Preview
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(theme, "Receipt Preview"),
                  const SizedBox(height: 16),
                  _buildReceiptPreview(theme),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.labelMedium?.copyWith(
        color: AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildTextField(
    ThemeData theme,
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptPreview(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo placeholder
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Symbols.store,
              color: AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(height: 10),

          // Shop name
          Text(
            _shopNameController.text.isEmpty
                ? "Shop Name"
                : _shopNameController.text,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // Address
          Text(
            _addressController.text.isEmpty
                ? "Address"
                : _addressController.text,
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
            textAlign: TextAlign.center,
          ),

          // Phone
          Text(
            _phoneController.text.isEmpty ? "Phone" : _phoneController.text,
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),
          _buildDashedDivider(),
          const SizedBox(height: 12),

          // Date & Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "12/03/2026",
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
              ),

              Text(
                "10:45 AM",
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
              ),
            ],
          ),

          const SizedBox(height: 12),
          _buildDashedDivider(),
          const SizedBox(height: 12),

          // Sample Items
          _buildReceiptItem(
            theme,
            "Item 1",
            "x2",
            "${AppNumberFormat.formatNumber(200)} LKR",
          ),
          _buildReceiptItem(
            theme,
            "Item 2",
            "x1",
            "${AppNumberFormat.formatNumber(150)} LKR",
          ),
          _buildReceiptItem(
            theme,
            "Item 3",
            "x3",
            "${AppNumberFormat.formatNumber(450)} LKR",
          ),

          const SizedBox(height: 8),
          _buildDashedDivider(),
          const SizedBox(height: 8),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "TOTAL",
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                "${AppNumberFormat.formatNumber(800)} LKR",
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          _buildDashedDivider(),
          const SizedBox(height: 12),

          // Footer
          Text(
            _footerController.text.isEmpty
                ? "Footer message"
                : _footerController.text,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptItem(
    ThemeData theme,
    String name,
    String qty,
    String price,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11)),
          Text(qty, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11)),
          Text(
            price,
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildDashedDivider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashWidth = 5.0;
        final dashSpace = 3.0;
        final count = (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          children: List.generate(
            count,
            (_) => Container(
              width: dashWidth,
              height: 1,
              margin: EdgeInsets.only(right: dashSpace),
              color: AppColors.divider,
            ),
          ),
        );
      },
    );
  }
}
