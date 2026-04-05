import 'dart:io';
import 'package:bvibe/const/theme/theme.dart';
import 'package:bvibe/const/snack/app.snack.dart';
import 'package:bvibe/data/model/item.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class AddItems extends StatefulWidget {
  final dynamic currentCategory;
  final int categoryIndex;

  const AddItems({
    super.key,
    required this.currentCategory,
    required this.categoryIndex,
  });

  static Future<ItemModel?> show(
    BuildContext context,
    dynamic currentCategory,
    int categoryIndex,
  ) async {
    return await showGeneralDialog<ItemModel>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Add Item",
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => const SizedBox(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return ScaleTransition(
          scale: curvedAnimation,
          child: FadeTransition(
            opacity: animation,
            child: AddItems(
              currentCategory: currentCategory,
              categoryIndex: categoryIndex,
            ),
          ),
        );
      },
    );
  }

  @override
  State<AddItems> createState() => _AddItemsState();
}

class _AddItemsState extends State<AddItems> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  File? _selectedImage;

  bool isRetail = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add New Item',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(
                  context,
                ).copyWith(scrollbars: false),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Image Placeholder
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.inputFill,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.inputBorder,
                              width: 1,
                            ),
                            image: _selectedImage != null
                                ? DecorationImage(
                                    image: FileImage(_selectedImage!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _selectedImage == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 40,
                                      color: AppColors.textHint,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "Add Item Image",
                                      style: TextStyle(
                                        color: AppColors.textHint,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildTextField(
                        context,
                        label: 'Item Name',
                        controller: _nameController,
                        hint: 'e.g. Thai Fried Rice',
                        icon: Icons.fastfood_outlined,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        context,
                        label: 'Description',
                        controller: _descController,
                        hint: 'Description about the item...',
                        icon: Icons.description_outlined,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              context,
                              label: 'Price (LKR)',
                              controller: _priceController,
                              hint: '1000',
                              icon: Icons.attach_money,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Checkbox(
                            value: isRetail,
                            onChanged: (value) {
                              setState(() {
                                isRetail = value ?? false;
                              });
                            },
                          ),
                          Text("Is Retail",style: Theme.of(context).textTheme.labelSmall,),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(
                          color: AppColors.inputBorder,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        final name = _nameController.text.trim();
                        final desc = _descController.text.trim();
                        final price = _priceController.text.trim();

                        if (name.isEmpty ||
                            price.isEmpty ||
                            _selectedImage == null) {
                          AppSnack.errorSnack(
                            context,
                            "Please fill all required fields and select an image",
                          );
                          return;
                        }

                        // Copy image to the project folder
                        final currentPath = Directory.current.path;
                        final imagesDir = Directory(
                          '$currentPath/assets/items',
                        );
                        if (!await imagesDir.exists()) {
                          await imagesDir.create(recursive: true);
                        }

                        final ext = p.extension(_selectedImage!.path);
                        final newImagePath =
                            '${imagesDir.path}/${DateTime.now().millisecondsSinceEpoch}$ext';
                        final savedImage = await _selectedImage!.copy(
                          newImagePath,
                        );

                        // Prepare ItemModel
                        final itemModel = ItemModel(
                          categoryId: widget.currentCategory.id ?? "",
                          itemName: name,
                          description: desc,
                          price: price,
                          imagePath: savedImage.path,
                          isRetail: isRetail,
                        );

                        Navigator.of(context).pop(itemModel);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Save Item',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: Theme.of(context).textTheme.labelMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppColors.textHint),
            prefixIcon: maxLines == 1
                ? Icon(icon, color: AppColors.textHint)
                : Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Icon(icon, color: AppColors.textHint),
                  ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: AppColors.inputFill,
          ),
        ),
      ],
    );
  }
}
