import 'package:bvibe/const/theme/theme.dart';
import 'package:bvibe/data/model/receipt.model.dart';
import 'package:bvibe/data/workspace/number.format.dart';
import 'package:flutter/material.dart';

class CheckoutOrderSummary extends StatefulWidget {
  final ReceiptModel receipt;
  const CheckoutOrderSummary({super.key, required this.receipt});

  @override
  State<CheckoutOrderSummary> createState() => _CheckoutOrderSummaryState();
}

class _CheckoutOrderSummaryState extends State<CheckoutOrderSummary> {
  final TextEditingController _discountController = TextEditingController(
    text: "10",
  );

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double itemDiscounts = 0;
    double netTotal = 0;
    for (var item in widget.receipt.items) {
      double price = double.tryParse(item.price) ?? 0;
      double discount = double.tryParse(item.discount) ?? 0;
      int qty = int.tryParse(item.qty) ?? 0;
      netTotal += (price - discount) * qty;
      itemDiscounts += discount * qty;
    }

    bool isRetail = widget.receipt.items.isNotEmpty &&
        widget.receipt.items.every((item) => item.isRetail);
    bool isTakeaway = widget.receipt.orderType == 'Takeaway';
    bool shouldExcludeServiceCharge = isRetail || isTakeaway;

    double billDiscount = double.tryParse(widget.receipt.totalDiscount) ?? 0.0;
    double amountToTax = netTotal - billDiscount;
    double serviceCharge = shouldExcludeServiceCharge 
        ? 0 
        : (amountToTax > 0 ? amountToTax * 0.10 : 0);
    double grandTotal = (netTotal - billDiscount) + serviceCharge;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.all(30),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Order Summary",
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 30),

            // Summary Bottom Area (Moved to Top)
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left text info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSubtleRow(
                        context,
                        "Subtotal",
                        "${AppNumberFormat.formatNumber(netTotal)} LKR",
                      ),
                      const SizedBox(height: 15),

                      // Item Discounts
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Item Discounts",
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 16,
                                ),
                          ),
                          Text(
                            "-${AppNumberFormat.formatNumber(itemDiscounts)} LKR",
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                          ),
                        ],
                      ),

                      if (billDiscount > 0) ...[
                        const SizedBox(height: 15),
                        // Bill Discount
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Bill Discount (Ctrl+D)",
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              "-${AppNumberFormat.formatNumber(billDiscount)} LKR",
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                  ),
                            ),
                          ],
                        ),
                      ],

                      if (!shouldExcludeServiceCharge) ...[
                        const SizedBox(height: 15),
                        _buildSubtleRow(
                          context,
                          "Service Charge (10%)",
                          "${AppNumberFormat.formatNumber(serviceCharge)} LKR",
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Grand Total (Moved to Top)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "TOTAL",
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  "${AppNumberFormat.formatNumber(grandTotal)} LKR",
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    fontSize: 38,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 25),

            // Table Headers
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: _buildTableHeader(context, "ITEM DESCRIPTION"),
                ),
                Expanded(
                  flex: 1,
                  child: _buildTableHeader(
                    context,
                    "QTY",
                    align: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: _buildTableHeader(
                    context,
                    "PRICE",
                    align: TextAlign.right,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: _buildTableHeader(
                    context,
                    "TOTAL",
                    align: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 20),

            // Items List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: widget.receipt.items.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 40, color: AppColors.divider),
              itemBuilder: (context, index) {
                return _buildSummaryItemRow(
                  context,
                  widget.receipt.items[index].itemName,
                  int.parse(widget.receipt.items[index].qty),
                  double.parse(widget.receipt.items[index].price),
                  (int.parse(widget.receipt.items[index].qty) *
                      double.parse(widget.receipt.items[index].price)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(
    BuildContext context,
    String title, {
    TextAlign align = TextAlign.left,
  }) {
    return Text(
      title,
      textAlign: align,
      style: Theme.of(context).textTheme.labelSmall!.copyWith(
        color: AppColors.textHint,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildSummaryItemRow(
    BuildContext context,
    String name,
    int qty,
    double price,
    double total,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            name,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            qty.toString(),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            "${AppNumberFormat.formatNumber(price)} LKR",
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            "${AppNumberFormat.formatNumber(total)} LKR",
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubtleRow(BuildContext context, String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
        Text(
          amount,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
