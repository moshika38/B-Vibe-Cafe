import 'dart:io';

import 'package:bvibe/components/app.buttons.dart';
import 'package:bvibe/const/snack/app.snack.dart';
import 'package:bvibe/const/theme/theme.dart';
import 'package:bvibe/data/model/invoice.data.model.dart';
import 'package:bvibe/provider/business.info.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class BusinessPage extends StatefulWidget {
  const BusinessPage({super.key});

  @override
  State<BusinessPage> createState() => _BusinessPageState();
}

class _BusinessPageState extends State<BusinessPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _tagLineController = TextEditingController();

  File? _logoFile;
  String? _existingLogoPath;
  final _picker = ImagePicker();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final provider = Provider.of<BusinessInfoProvider>(
        context,
        listen: false,
      );
      final settings = await provider.getSettings();

      if (settings != null && mounted) {
        _nameController.text = settings.businessName;
        _emailController.text = settings.businessEmail;
        _phoneController.text = settings.businessNumber;
        _addressController.text = settings.businessAddress;
        _tagLineController.text = settings.tagLine;
        _existingLogoPath = settings.businessLogo;
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _tagLineController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      setState(() => _logoFile = File(picked.path));
    }
  }

  Future<void> _saveChanges() async {
    final provider = Provider.of<BusinessInfoProvider>(context, listen: false);

    final settings = BusinessInfoModel(
      id: provider.invoiceData?.id,
      businessName: _nameController.text,
      businessEmail: _emailController.text,
      businessAddress: _addressController.text,
      businessNumber: _phoneController.text,
      businessLogo: _logoFile?.path ?? _existingLogoPath ?? "",
      tagLine: _tagLineController.text,
    );

    await provider.saveSettings(settings);

    if (mounted) {
      AppSnack.successSnack(context, "Settings saved successfully!");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            "Business Info",
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Manage your business profile.",
            style: theme.textTheme.labelSmall,
          ),

          const SizedBox(height: 30),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Left — form
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo picker
                  _sectionTitle(theme, "Business Logo"),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _pickLogo,
                    child: Row(
                      children: [
                        // Logo preview
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                            image: _logoFile != null
                                ? DecorationImage(
                                    image: FileImage(_logoFile!),
                                    fit: BoxFit.cover,
                                  )
                                : (_existingLogoPath != null &&
                                      _existingLogoPath!.isNotEmpty)
                                ? DecorationImage(
                                    image: FileImage(File(_existingLogoPath!)),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child:
                              (_logoFile == null &&
                                  (_existingLogoPath == null ||
                                      _existingLogoPath!.isEmpty))
                              ? const Icon(
                                  Symbols.store,
                                  color: AppColors.primary,
                                  size: 32,
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.divider),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.textSecondary.withValues(
                                      alpha: 0.06,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Symbols.upload,
                                    size: 16,
                                    color: AppColors.textPrimary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _logoFile == null
                                        ? "Upload Logo"
                                        : "Change Logo",
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "PNG or JPG, recommended 512×512",
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Fields
                  _sectionTitle(theme, "Details"),
                  const SizedBox(height: 16),

                  _field(
                    theme,
                    label: "Business Name",
                    controller: _nameController,
                    icon: Symbols.store,
                  ),
                  const SizedBox(height: 12),
                  _field(
                    theme,
                    label: "Email",
                    controller: _emailController,
                    icon: Symbols.mail,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  _field(
                    theme,
                    label: "Phone",
                    controller: _phoneController,
                    icon: Symbols.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  _field(
                    theme,
                    label: "Address",
                    controller: _addressController,
                    icon: Symbols.location_on,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  _field(
                    theme,
                    label: "Tag Line",
                    controller: _tagLineController,
                    icon: Symbols.tag_sharp,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 200,
                    child: AppButtons(
                      text: "Save Changes",
                      onTap: _saveChanges,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 30),

            // Right — live preview
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(theme, "Receipt Preview"),
                  const SizedBox(height: 16),
                  _buildPreviewCard(theme),
                  const SizedBox(height: 30),
                  _sectionTitle(theme, "KOT Preview"),
                  const SizedBox(height: 16),
                  _buildKOTPreviewCard(theme),
                ],
              ),
            ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.labelMedium?.copyWith(
        color: AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _field(
    ThemeData theme, {
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsets.only(top: maxLines > 1 ? 10 : 0),
              child: Icon(icon, size: 18, color: AppColors.textSecondary),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewCard(ThemeData theme) {
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
        children: [
          // Receipt Header
          if (_logoFile != null ||
              (_existingLogoPath != null && _existingLogoPath!.isNotEmpty))
            Container(
              width: 52,
              height: 52,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                image: _logoFile != null
                    ? DecorationImage(
                        image: FileImage(_logoFile!),
                        fit: BoxFit.cover,
                      )
                    : DecorationImage(
                        image: FileImage(File(_existingLogoPath!)),
                        fit: BoxFit.cover,
                      ),
              ),
            )
          else
            Container(
              width: 52,
              height: 52,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Symbols.store,
                color: AppColors.primary,
                size: 24,
              ),
            ),

          Text(
            _nameController.text.isEmpty ? "BUSINESS NAME" : _nameController.text.toUpperCase(),
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 6),
          if (_addressController.text.isNotEmpty)
            Text(
              _addressController.text,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          if (_phoneController.text.isNotEmpty)
            Text(
              _phoneController.text,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),

          const SizedBox(height: 20),
          _receiptDivider(),
          const SizedBox(height: 16),

          // Mini placeholder for items to give receipt feel
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("ITEM", style: _receiptHeaderStyle(theme)),
              Text("QTY", style: _receiptHeaderStyle(theme)),
              Text("TOTAL", style: _receiptHeaderStyle(theme)),
            ],
          ),
          const SizedBox(height: 8),
          _receiptLineItem(theme, "Sample Coffee", "1", "LKR 450.00"),
          const SizedBox(height: 4),
          _receiptLineItem(theme, "Butter Croissant", "2", "LKR 700.00"),

          const SizedBox(height: 16),
          _receiptDivider(),
          const SizedBox(height: 16),

          // Tagline / Footer
          Text(
            "THANK YOU!",
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 4),
          if (_tagLineController.text.isNotEmpty)
            Text(
              _tagLineController.text,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }

  Widget _receiptDivider() {
    return Row(
      children: List.generate(
        30,
        (index) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
            height: 1,
            color: AppColors.divider,
          ),
        ),
      ),
    );
  }

  TextStyle? _receiptHeaderStyle(ThemeData theme) {
    return theme.textTheme.labelSmall?.copyWith(
      color: AppColors.textSecondary.withValues(alpha: 0.6),
      fontSize: 9,
      fontWeight: FontWeight.w600,
      letterSpacing: 1,
    );
  }

  Widget _receiptLineItem(ThemeData theme, String name, String qty, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            name,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textPrimary,
              fontSize: 10,
            ),
          ),
        ),
        SizedBox(
          width: 30,
          child: Text(
            qty,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ),
        SizedBox(
          width: 70,
          child: Text(
            price,
            textAlign: TextAlign.right,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKOTPreviewCard(ThemeData theme) {
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
        children: [
          Text(
            "KITCHEN ORDER TOKEN",
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          _receiptDivider(),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Order: #1234", style: _kotInfoStyle(theme)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "TAKEAWAY",
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.surface,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Time: 12:45 PM", style: _kotInfoStyle(theme)),
          ),

          const SizedBox(height: 16),
          _receiptDivider(),
          const SizedBox(height: 16),

          // KOT Items — No prices, focused on Name and Qty
          _kotLineItem(theme, "Sample Coffee", "1"),
          const SizedBox(height: 8),
          _kotLineItem(theme, "Butter Croissant", "2"),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "  Note: Extra butter, please.",
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 9,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          const SizedBox(height: 20),
          _receiptDivider(),
        ],
      ),
    );
  }

  TextStyle? _kotInfoStyle(ThemeData theme) {
    return theme.textTheme.labelSmall?.copyWith(
      color: AppColors.textPrimary,
      fontSize: 10,
      fontWeight: FontWeight.w600,
    );
  }

  Widget _kotLineItem(ThemeData theme, String name, String qty) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            name,
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          "x$qty",
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
