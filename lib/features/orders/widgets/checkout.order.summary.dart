import 'package:bvibe/const/theme.dart';
import 'package:flutter/material.dart';

class CheckoutOrderSummary extends StatefulWidget {
  const CheckoutOrderSummary({super.key});

  @override
  State<CheckoutOrderSummary> createState() => _CheckoutOrderSummaryState();
}

class _CheckoutOrderSummaryState extends State<CheckoutOrderSummary> {
  final TextEditingController _discountController = TextEditingController(text: "10");

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      _buildSubtleRow(context, "Subtotal", "\$84.00"),
                      const SizedBox(height: 15),
                      
                      // Editable Discount Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Discount",
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 15),
                              SizedBox(
                                width: 80,
                                height: 35,
                                child: TextField(
                                  controller: _discountController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                    isDense: true,
                                    suffixText: "%",
                                    filled: true,
                                    fillColor: AppColors.inputFill,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: AppColors.divider),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: AppColors.divider),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "-\$8.40",
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 15),
                      _buildSubtleRow(context, "Tax (15%)", "\$11.34"),
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
                  "\$86.94",
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
                  child: _buildTableHeader(context, "QTY", align: TextAlign.center),
                ),
                Expanded(
                  flex: 2,
                  child: _buildTableHeader(context, "PRICE", align: TextAlign.right),
                ),
                Expanded(
                  flex: 2,
                  child: _buildTableHeader(context, "TOTAL", align: TextAlign.right),
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
              itemCount: 3, // Dummy data
              separatorBuilder: (context, index) => const Divider(height: 40, color: AppColors.divider),
              itemBuilder: (context, index) {
                return _buildSummaryItemRow(
                  context, 
                  "Smoked Salmon Smørrebrød", 
                  "Gluten-free rye bread, dill cream",
                  2, 
                  18.00,
                  36.00,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context, String title, {TextAlign align = TextAlign.left}) {
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

  Widget _buildSummaryItemRow(BuildContext context, String name, String desc, int qty, double price, double total) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            qty.toString(),
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
            "\$${price.toStringAsFixed(2)}",
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
            "\$${total.toStringAsFixed(2)}",
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
