import 'package:bvibe/components/app.buttons.dart';
import 'dart:io';
import 'package:bvibe/const/theme/theme.dart';
import 'package:bvibe/const/snack/app.snack.dart';
import 'package:bvibe/data/model/item.model.dart';
import 'package:bvibe/provider/item.provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart' as p;

class EditItemCart extends StatefulWidget {
  final String id;
  final String name;
  final String image;
  final String price;
  final String categoryId;
  final String categoryName;
  final String des;
  final bool isRetail;

  const EditItemCart({
    super.key,
    required this.name,
    required this.image,
    required this.price,
    required this.categoryId,
    required this.categoryName,
    required this.id,
    required this.des,
    required this.isRetail,
  });

  @override
  State<EditItemCart> createState() => _EditItemCartState();
}

class _EditItemCartState extends State<EditItemCart> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;
  late TextEditingController _desController;

  File? _newImage;

  bool isRetail = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _checkIsRetail();
  }

  void _checkIsRetail() {
    setState(() {
      isRetail = widget.isRetail;
    });
  }

  void _initControllers() {
    _nameController = TextEditingController(text: widget.name);
    _priceController = TextEditingController(text: widget.price);
    _categoryController = TextEditingController(text: widget.categoryName);
    _desController = TextEditingController(text: widget.des);
    _newImage = null;
  }

  @override
  void didUpdateWidget(EditItemCart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id || oldWidget.name != widget.name) {
      _nameController.text = widget.name;
      _priceController.text = widget.price;
      _categoryController.text = widget.categoryName;
      _desController.text = widget.des;
      _newImage = null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _desController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    final name = _nameController.text.trim();
    final price = _priceController.text.trim();
    final des = _desController.text.trim();

    if (name.isEmpty || price.isEmpty) {
      AppSnack.errorSnack(context, "Name and Price are required");
      return;
    }

    String finalImagePath = widget.image;

    if (_newImage != null) {
      // Delete old image if it is a local file and not a bundled asset
      if (!widget.image.contains('assets/img/')) {
        final oldImageFile = File(widget.image);
        if (await oldImageFile.exists()) {
          try {
            await oldImageFile.delete();
          } catch (e) {
            debugPrint("Error deleting old image: $e");
          }
        }
      }

      // Save new image to assets/items
      final currentPath = Directory.current.path;
      final imagesDir = Directory('$currentPath/assets/items');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      final ext = p.extension(_newImage!.path);
      final newImagePath =
          '${imagesDir.path}/${DateTime.now().millisecondsSinceEpoch}$ext';
      final savedImage = await _newImage!.copy(newImagePath);
      finalImagePath = savedImage.path;
    }

    final updatedItem = ItemModel(
      id: widget.id,
      categoryId: widget.categoryId,
      itemName: name,
      description: des,
      price: price,
      imagePath: finalImagePath,
      isRetail: isRetail,
    );

    try {
      await ItemProvider.instance.updateItem(updatedItem);
      if (mounted) {
        AppSnack.successSnack(context, "Item updated successfully");
        setState(() {
          _newImage = null; // Reset image state
        });
      }
    } catch (e) {
      if (mounted) {
        AppSnack.errorSnack(context, "Failed to update item");
      }
    }
  }

  Future<void> _deleteItem() async {
    try {
      await ItemProvider.instance.deleteItem(widget.id);

      // Delete the image file if it is not a bundled asset
      if (!widget.image.contains('assets/img/')) {
        final imageFile = File(widget.image);
        if (await imageFile.exists()) {
          try {
            await imageFile.delete();
          } catch (e) {
            debugPrint("Error deleting image: $e");
          }
        }
      }

      if (mounted) {
        AppSnack.successSnack(context, "Item deleted successfully");
      }
    } catch (e) {
      if (mounted) {
        AppSnack.errorSnack(context, "Failed to delete item");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          // Header
          Row(
            children: [
              Text(
                "Edit Item".toUpperCase(),
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.grey, thickness: 0.2),
          const SizedBox(height: 20),

          // scrollable content
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: _newImage != null
                              ? Image.file(
                                  _newImage!,
                                  height: 400,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : widget.image.contains('assets/img/')
                              ? Image.asset(
                                  widget.image,
                                  height: 400,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(widget.image),
                                  height: 400,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const SizedBox(
                                        height: 400,
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 80,
                                        ),
                                      ),
                                ),
                        ),
                        Positioned(
                          top: 20,
                          right: 20,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    textInput(theme, "Item Name", _nameController),
                    textInput(
                      theme,
                      "Price(LKR)",
                      _priceController,
                      isNumber: true,
                    ),
                    textInput(
                      theme,
                      "Category",
                      _categoryController,
                      readOnly: true,
                    ),
                    textInput(theme, "Description", _desController),
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
                        Text(
                          "Is Retail",
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // buttons always visible
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButtons(
                icon: Symbols.delete,
                text: "Delete Item",
                onTap: _deleteItem,
                isNotPrimary: true,
              ),
              const SizedBox(width: 20),
              AppButtons(
                icon: Symbols.save,
                text: "Save Changes",
                onTap: _saveChanges,
                isNotPrimary: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget textInput(
    ThemeData theme,
    String labelText,
    TextEditingController controller, {
    bool isNumber = false,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(labelText, style: theme.textTheme.labelSmall),
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          child: TextFormField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            readOnly: readOnly,
            style: theme.textTheme.labelMedium,
            decoration: InputDecoration(
              hintText: labelText.toUpperCase(),
              hintStyle: theme.textTheme.labelMedium!.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w200,
                fontSize: 11,
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: Colors.grey, width: 0.5),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
