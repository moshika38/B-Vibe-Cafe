import 'package:bvibe/data/model/receipt.model.dart';
import 'package:bvibe/provider/receipt.provider.dart';
import 'package:flutter/material.dart';
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
            border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.receipt_long_rounded,
                size: 16,
                color: Color(0xFF6B6B6B),
              ),
              const SizedBox(width: 8),
              Text(
                "Order Items  ",
                style: theme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
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
                    child: Text(
                      "No items",
                      style: Theme.of(context).textTheme.labelSmall,
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
                child: Text(
                  "No items",
                  style: Theme.of(context).textTheme.labelSmall,
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
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Text(
        "${index + 1}. $itemName",
        style: theme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A1A1A),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
