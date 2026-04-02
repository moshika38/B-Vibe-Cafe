import 'package:bvibe/components/conform.window.dart';
import 'package:bvibe/const/theme/theme.dart';
import 'package:bvibe/features/orders/widgets/empty.item.dart';
import 'package:bvibe/data/workspace/number.format.dart';
import 'package:bvibe/provider/receipt.provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EmptyCard extends StatelessWidget {
  final String receiptId;
  const EmptyCard({super.key, required this.receiptId});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Current Order",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Total ${AppNumberFormat.formatNumber(50)} LKR",
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            Divider(),
          ],
        ),

        EmptyItem(),

        _buildCheckOutSection(context),
      ],
    );
  }

  Widget _buildCheckOutSection(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Discount",
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            Text(
              "${AppNumberFormat.formatNumber(0)} LKR",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Net Amount",
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            SizedBox(
              width: 220,
              child: Text(
                "${AppNumberFormat.formatNumber(0)} LKR",
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
                      value.deleteReceipt(receiptId);
                    }
                  },
                  icon: Icon(Icons.delete, size: 25),
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                child: Text(
                  "Place Order",
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: AppColors.surface,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
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
