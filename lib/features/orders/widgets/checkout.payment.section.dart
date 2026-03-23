import 'package:bvibe/const/theme.dart';
import 'package:flutter/material.dart';

class CheckoutPaymentSection extends StatefulWidget {
  const CheckoutPaymentSection({super.key});

  @override
  State<CheckoutPaymentSection> createState() => _CheckoutPaymentSectionState();
}

class _CheckoutPaymentSectionState extends State<CheckoutPaymentSection> {
  String selectedPayment = "Cash";
  final TextEditingController _amountReceivedController = TextEditingController(
    text: "100.00",
  );

  bool isPaid = false;

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

            const SizedBox(height: 40),

            Text(
              "AMOUNT RECEIVED",
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                color: AppColors.textHint,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),

            // Amount Received Field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Text(
                    "\$",
                    style: TextStyle(
                      fontSize: 28,
                      color: AppColors.textHint,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _amountReceivedController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Change Return Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9), // Light green
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFF00C853), // Green
                        radius: 20,
                        child: Icon(
                          Icons.change_circle,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "CHANGE RETURN",
                            style: Theme.of(context).textTheme.labelSmall!
                                .copyWith(
                                  color: const Color(0xFF00C853),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "\$13.06",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF00C853),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Opacity(
                    opacity: 0.3,
                    child: CircleAvatar(
                      backgroundColor: Color(0xFF00C853),
                      radius: 16,
                      child: Text(
                        "\$",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: !isPaid
                    ? () {
                        setState(() {
                          isPaid = true;
                        });
                        print("Order confirmed");
                      }
                    : null,

                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  backgroundColor: isPaid
                      ? AppColors.textSecondary
                      : AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 24,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Confirm Payment",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: isPaid
                    ? () {
                        print("print receipt");
                      }
                    : null,
                style: OutlinedButton.styleFrom(
                  backgroundColor: isPaid
                      ? AppColors.primary
                      : AppColors.inputBorder,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  side: BorderSide(
                    color: isPaid ? AppColors.primary : AppColors.inputBorder,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 24,
                      color: isPaid
                          ? AppColors.background
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Print Receipt",
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: isPaid
                            ? AppColors.background
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
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
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : AppColors.background,
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.divider.withValues(alpha: 0.4),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 32,
            ),
            const SizedBox(height: 12),
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
