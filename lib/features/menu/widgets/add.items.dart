 import 'package:flutter/material.dart';

class AddItems extends StatefulWidget {
  final dynamic currentCategory;
  final int categoryIndex;

  const AddItems({
    super.key,
    required this.currentCategory,
    required this.categoryIndex,
  });

  static Future<void> show(
    BuildContext context,
    dynamic currentCategory,
    int categoryIndex,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AddItems(
        currentCategory: currentCategory,
        categoryIndex: categoryIndex,
      ),
    );
  }

  @override
  State<AddItems> createState() => _AddItemsState();
}

class _AddItemsState extends State<AddItems> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox( 
      ),
    );
  }
}
