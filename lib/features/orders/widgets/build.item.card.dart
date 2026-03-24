import 'dart:io';
import 'package:bvibe/const/theme.dart';
import 'package:bvibe/data/model/receipt.model.dart';
import 'package:bvibe/provider/receipt.provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BuildItemCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<ReceiptProvider>(
      builder: (context, value, child) => Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: image.startsWith("assets/")
                      ? Image.asset(
                          image,
                          height: 130,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(image),
                          height: 130,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),

                /// subtle gradient
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.25),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// TITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall!.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 6),

            /// PRICE + ADD BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// PRICE
                  Text(
                    price,
                    style: theme.textTheme.titleSmall!.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  /// ADD BUTTON
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      // add item
                      value.addOrIncrementItem(
                        receiptId,
                        ReceiptItemsModel(
                          id: itemId,
                          category: cate,
                          itemName: title,
                          description: des,
                          price: price,
                          cost: cost,
                          imagePath: image,
                          qty: "1",
                          netAmount: price,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
