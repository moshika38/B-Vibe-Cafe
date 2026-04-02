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
        _tagLineController.text = settings.thankYouText;
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
      thankYouText: _tagLineController.text,
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

    return Column(
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
                  _sectionTitle(theme, "Preview"),
                  const SizedBox(height: 16),
                  _buildPreviewCard(theme),
                ],
              ),
            ),
          ],
        ),
      ],
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo + name
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
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
                        size: 24,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _nameController.text.isEmpty
                      ? "Business Name"
                      : _nameController.text,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 14),

          _previewRow(theme, Symbols.mail, _emailController.text),
          _previewRow(theme, Symbols.phone, _phoneController.text),
          _previewRow(theme, Symbols.location_on, _addressController.text),
        ],
      ),
    );
  }

  Widget _previewRow(ThemeData theme, IconData icon, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
