import 'package:bvibe/const/theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class CheckoutWidgets {
  Widget buildCheckOutInputBars(
    BuildContext context,
    TextEditingController amountReceivedController,
    String title,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
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
                "LKR",
                style: TextStyle(
                  fontSize: 30,
                  color: AppColors.textHint,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: amountReceivedController,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildReturnChangeCard(BuildContext context) {
    return Container(
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
                child: Icon(Icons.change_circle, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "CHANGE RETURN",
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
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
    );
  }

  Widget buildConformActionBtn(
    BuildContext context,
    bool isConform,
    VoidCallback onTap,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,

        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 24),
          backgroundColor: isConform
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
            const Icon(Icons.check_circle, size: 24, color: Colors.white),
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
    );
  }

  Widget buildPrintReceiptBtn(
    BuildContext context,
    bool isConform,
    VoidCallback onTap,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: isConform
              ? AppColors.primary
              : AppColors.inputBorder,
          padding: const EdgeInsets.symmetric(vertical: 20),
          side: BorderSide(
            color: isConform ? AppColors.primary : AppColors.inputBorder,
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
              color: isConform ? AppColors.background : AppColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Text(
              "Print Receipt",
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: isConform
                    ? AppColors.background
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
