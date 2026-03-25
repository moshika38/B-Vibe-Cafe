import 'dart:io';

import 'package:bvibe/components/conform.window.dart';
import 'package:bvibe/const/theme.dart';
import 'package:bvibe/data/model/receipt.model.dart';
import 'package:bvibe/data/workspace/number.format.dart';
import 'package:bvibe/features/orders/widgets/empty.card.dart';
import 'package:bvibe/features/orders/widgets/empty.item.dart';
import 'package:bvibe/provider/receipt.provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CurrentOrder extends StatefulWidget {
  final String receiptId;
  const CurrentOrder({super.key, required this.receiptId});

  @override
  State<CurrentOrder> createState() => _CurrentOrderState();
}

class _CurrentOrderState extends State<CurrentOrder> {
  double tot = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(16),
      child: Consumer<ReceiptProvider>(
        builder: (context, value, child) {
          return FutureBuilder(
            future: value.getReceipt(widget.receiptId),
            builder: (context, asyncSnapshot) {
              if (asyncSnapshot.hasData) {
                final data = asyncSnapshot.data;
                if (data!.items.isEmpty) {
                  return EmptyCard(receiptId: widget.receiptId);
                }

                tot = double.parse(data.totalAmount);

                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ... header
                    Expanded(
                      child: ListView.builder(
                        itemCount: data.items.length,
                        itemBuilder: (context, index) {
                          final item = data.items[index];
                          return _buildItemCard(
                            context,
                            item.itemName,
                            item.price,
                            item.imagePath,
                            int.parse(item.qty),
                            (int.parse(item.qty) * double.parse(item.price))
                                .toString(),
                            () async {
                              // + button
                              await value.addOrIncrementItem(
                                widget.receiptId,
                                ReceiptItemsModel(
                                  id: item.id,
                                  category: item.category,
                                  itemName: item.itemName,
                                  description: item.description,
                                  price: item.price,
                                  cost: item.cost,
                                  imagePath: item.imagePath,
                                  qty: "1",
                                  netAmount: item.price,
                                ),
                              );
                            },
                            () async {
                              // - button
                              final receipt = await value.getReceipt(
                                widget.receiptId,
                              );
                              if (receipt == null) return;

                              final currentQty = int.parse(item.qty);
                              List<ReceiptItemsModel> updatedItems;

                              if (currentQty <= 1) {
                                updatedItems = receipt.items
                                    .where((e) => e.id != item.id)
                                    .toList();
                              } else {
                                updatedItems = receipt.items.map((e) {
                                  if (e.id == item.id) {
                                    final newQty = (currentQty - 1).toString();
                                    return ReceiptItemsModel(
                                      id: e.id,
                                      category: e.category,
                                      itemName: e.itemName,
                                      description: e.description,
                                      price: e.price,
                                      cost: e.cost,
                                      imagePath: e.imagePath,
                                      qty: newQty,
                                      netAmount:
                                          ((currentQty - 1) *
                                                  double.parse(e.price))
                                              .toString(),
                                    );
                                  }
                                  return e;
                                }).toList();
                              }

                              await value.updateReceiptItems(
                                widget.receiptId,
                                updatedItems,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Divider(),
                    SizedBox(height: 20),
                    _buildCheckOutSection(context, tot.toString()),
                  ],
                );
              }
              return EmptyItem();
            },
          );
        },
      ),
    );
  }

  Widget _buildCheckOutSection(BuildContext context, String total) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Amount".toUpperCase(),
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            SizedBox(
              width: 220,
              child: Text(
                "${AppNumberFormat.formatNumber(double.parse(total))} LKR",
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 20),

        Row(
          children: [
            Consumer<ReceiptProvider>(
              builder: (context, value, child) => Card(
                color: AppColors.background,
                child: IconButton(
                  onPressed: () async {
                    final isValid = await showPinDialog(context);
                    if (isValid) {
                      context.go('/orders');
                      value.deleteReceipt(widget.receiptId);
                    }
                  },
                  icon: Icon(Icons.delete, size: 25),
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // go to checkout page
                  context.push('/orders/checkout', extra: widget.receiptId);
                },
                child: Text(
                  "Place Order ( Num+Enter )",
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: AppColors.surface,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Widget _buildItemCard(
  BuildContext context,
  String name,
  String price,
  String image,
  int quantity,
  String total,
  VoidCallback onAdd,
  VoidCallback onRemove,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Card(
      color: AppColors.background,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: image.startsWith("assets/")
                  ? Image.asset(image, width: 60, height: 60, fit: BoxFit.cover)
                  : Image.file(
                      File(image),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
            ),
            SizedBox(width: 10),

            // ← fix
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  "${AppNumberFormat.formatNumber(double.parse(price))} LKR",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),

            Spacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    _buildIconBtn(false, onRemove),
                    SizedBox(width: 10),
                    Text(
                      quantity.toString(),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    SizedBox(width: 10),
                    _buildIconBtn(true, onAdd),
                  ],
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: Text(
                    "${AppNumberFormat.formatNumber(double.parse(total))} LKR",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildIconBtn(bool isAdd, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Icon(
      isAdd ? Icons.add : Icons.remove,
      color: AppColors.textPrimary,
      size: 20,
    ),
  );
}
