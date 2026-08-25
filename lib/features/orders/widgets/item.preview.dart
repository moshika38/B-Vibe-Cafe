import 'package:bvibe/const/theme/theme.dart';
import 'package:bvibe/data/model/receipt.model.dart';
import 'package:bvibe/provider/receipt.provider.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class ItemPreview extends StatelessWidget {
  final String invoiceId;
  const ItemPreview({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.divider)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Symbols.receipt_long, size: 14, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              Text(
                "Order Items",
                style: theme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),

        // List
        Consumer<ReceiptProvider>(
          builder: (context, value, child) => FutureBuilder<ReceiptModel?>(
            future: value.getReceipt(invoiceId),
            builder: (context, asyncSnapshot) {
              if (asyncSnapshot.hasData) {
                final data = asyncSnapshot.data;
                if (data == null || data.items.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      children: [
                        Icon(Symbols.shopping_bag, size: 16, color: AppColors.textTertiary),
                        const SizedBox(width: 8),
                        Text(
                          "No items",
                          style: theme.labelSmall?.copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  );
                }
                final items = data.items;
                return Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return _card(context, index, items[index].itemName);
                    },
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Loading items...",
                      style: theme.labelSmall?.copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _card(BuildContext context, int index, String itemName) {
    final theme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                "${index + 1}",
                style: theme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              itemName,
              style: theme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
