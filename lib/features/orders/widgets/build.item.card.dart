import 'dart:io';
import 'package:bvibe/const/theme.dart';
import 'package:bvibe/data/model/receipt.model.dart';
import 'package:bvibe/data/workspace/number.format.dart';
import 'package:bvibe/provider/receipt.provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BuildItemCard extends StatefulWidget {
  final String title;
  final String price;
  final String image;
  final bool isSelect;
  final String receiptId;
  final String itemId;
  final String cate;
  final String cost;
  final String des;
  
  const BuildItemCard({
    super.key,
    required this.title,
    required this.price,
    required this.image,
    required this.isSelect,
    required this.receiptId,
    required this.itemId,
    required this.cate,
    required this.cost,
    required this.des,
  });

  @override
  State<BuildItemCard> createState() => _BuildItemCardState();
}

class _BuildItemCardState extends State<BuildItemCard> {
  int _qty = 0; 
  double _discount = 0.0;
  late TextEditingController _qtyController;

  @override
  void initState() {
    super.initState();
    
    _qty = 1;
    _qtyController = TextEditingController(text: '1')
      ..selection = const TextSelection(baseOffset: 0, extentOffset: 1);
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  void _addOrUpdateItem(ReceiptProvider provider, int qtyDelta) {
    if (qtyDelta == 0) return;
    
    double basePrice = double.tryParse(widget.price) ?? 0.0;
    double finalPrice = basePrice * (1 - (_discount / 100));

    provider.addOrIncrementItem(
      widget.receiptId,
      ReceiptItemsModel(
        id: widget.itemId,
        category: widget.cate,
        itemName: widget.title,
        description: widget.des,
        price: finalPrice.toStringAsFixed(2),
        cost: widget.cost,
        imagePath: widget.image,
        qty: qtyDelta.toString(),
        netAmount: finalPrice.toStringAsFixed(2),
      ),
    );
  }

  void _increment(ReceiptProvider provider) {
    setState(() {
      _qty++;
      _qtyController.text = _qty.toString();
    });
    _addOrUpdateItem(provider, 1);
  }

  void _decrement(ReceiptProvider provider) {
    if (_qty > 0) {
      setState(() {
        _qty--;
        _qtyController.text = _qty.toString();
      });
      _addOrUpdateItem(provider, -1);
    }
  }

  void _onQtyChanged(String value, ReceiptProvider provider) {
    final int newQty = int.tryParse(value) ?? 1;
    if (newQty != _qty) {
      final int delta = newQty - _qty;
      setState(() {
        _qty = newQty;
      });
      _addOrUpdateItem(provider, delta);
    }
  }

  Future<void> _showDiscountDialog() async {
    double? updatedDiscount = await showDialog<double>(
      context: context,
      builder: (ctx) {
        TextEditingController ctrl = TextEditingController(text: _discount.toStringAsFixed(0));
        ctrl.selection = TextSelection(baseOffset: 0, extentOffset: ctrl.text.length);
        
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Apply Discount (%)', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              suffixText: '%',
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textHint)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(ctx, double.tryParse(ctrl.text)),
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );

    if (updatedDiscount != null && updatedDiscount >= 0 && updatedDiscount <= 100) {
      setState(() => _discount = updatedDiscount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final basePrice = double.tryParse(widget.price) ?? 0.0;
    final finalPrice = basePrice * (1 - (_discount / 100));

    return Consumer<ReceiptProvider>(
      builder: (context, value, child) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: widget.isSelect
              ? Border.all(color: AppColors.primary, width: 2)
              : Border.all(color: Colors.transparent, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: theme.colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// IMAGE
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      widget.image.startsWith("assets/")
                          ? Image.asset(
                              widget.image,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(widget.image),
                              fit: BoxFit.cover,
                            ),
                      
                      /// Subtle gradient for text readability if needed
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.4),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.5],
                            ),
                          ),
                        ),
                      ),
                      
                      /// Discount Badge
                      if (_discount > 0)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '-${_discount.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                /// DETAILS SECTION
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// TITLE
                      Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall!.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      /// PRICE
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "${AppNumberFormat.formatNumber(finalPrice)} LKR",
                            style: theme.textTheme.titleSmall!.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_discount > 0) ...[
                            const SizedBox(width: 6),
                            Text(
                              AppNumberFormat.formatNumber(basePrice),
                              style: theme.textTheme.labelSmall!.copyWith(
                                color: AppColors.textHint,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ]
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      /// CONTROLS (Discount & Qty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// Discount Option Button
                          InkWell(
                            onTap: _showDiscountDialog,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.local_offer_outlined,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          
                          /// Qty Control
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.divider),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                InkWell(
                                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
                                  onTap: () => _decrement(value),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(Icons.remove, size: 16, color: AppColors.textSecondary),
                                  ),
                                ),
                                Container(
                                  constraints: const BoxConstraints(minWidth: 40),
                                  width: 40,
                                  alignment: Alignment.center,
                                  child: TextField(
                                    controller: _qtyController,
                                    autofocus: true,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    style: theme.textTheme.labelLarge!.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                    ),
                                    onSubmitted: (val) => _onQtyChanged(val, value),
                                    onChanged: (val) {
                                      // Optional: Live update on typing
                                    },
                                  ),
                                ),
                                InkWell(
                                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
                                  onTap: () => _increment(value),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(Icons.add, size: 16, color: AppColors.primary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
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
