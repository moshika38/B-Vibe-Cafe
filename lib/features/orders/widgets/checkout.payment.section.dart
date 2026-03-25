import 'package:bvibe/const/theme.dart';
import 'package:bvibe/data/model/receipt.model.dart';
import 'package:bvibe/features/orders/widgets/checkout.widgets.dart';
import 'package:flutter/material.dart';

class CheckoutPaymentSection extends StatefulWidget {
  final ReceiptModel receipt;
  const CheckoutPaymentSection({super.key, required this.receipt});

  @override
  State<CheckoutPaymentSection> createState() => _CheckoutPaymentSectionState();
}

class _CheckoutPaymentSectionState extends State<CheckoutPaymentSection> {
  String selectedPayment = "Cash";
  final TextEditingController _amountReceivedController = TextEditingController(
    text: "5000.00",
  );

  bool isConform = false;

  @override
  void dispose() {
    _amountReceivedController.dispose();
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
              "Select Payment Method",
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 25),

            Row(
              children: [
                Expanded(
                  child: _buildPaymentOption("Cash", Icons.payments_outlined),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildPaymentOption(
                    "Card",
                    Icons.credit_card_outlined,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildPaymentOption(
                    "Transfer",
                    Icons.account_balance_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // CheckoutWidgets().buildCheckOutInputBars(
            //   context,
            //   _discountController,
            //   "DISCOUNT AMOUNT",
            // ),
            const SizedBox(height: 20),
            CheckoutWidgets().buildCheckOutInputBars(
              context,
              _amountReceivedController,
              "RECEIVED AMOUNT",
            ),

            const SizedBox(height: 20),

            // Change Return Box
            CheckoutWidgets().buildReturnChangeCard(context),

            const SizedBox(height: 40),

            // Action Buttons
            CheckoutWidgets().buildConformActionBtn(
              context,
              isConform,
              !isConform
                  ? () {
                      setState(() {
                        isConform = true;
                      });
                      print("Order confirmed");
                    }
                  : () {},
            ),
            const SizedBox(height: 15),
            CheckoutWidgets().buildPrintReceiptBtn(
              context,
              isConform,
              isConform
                  ? () {
                      print("print receipt");
                    }
                  : () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String title, IconData icon) {
    final isSelected = selectedPayment == title;
    return GestureDetector(
      onTap: () => setState(() => selectedPayment = title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 30),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : AppColors.background,
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.divider.withValues(alpha: 0.4),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
