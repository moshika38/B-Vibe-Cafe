import 'package:bvibe/const/theme.dart';
import 'package:bvibe/data/workspace/number.format.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class CheckoutWidgets {
  Widget buildCheckOutInputBars(
    BuildContext context,
    TextEditingController amountReceivedController,
    String title,
    ValueChanged<String> onChange, {
    FocusNode? focusNode,
    bool autofocus = false,
  }) {
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
                  autofocus: autofocus,
                  focusNode: focusNode,
                  onChanged: onChange,
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

  Widget buildReturnChangeCard(BuildContext context, String text, {bool isInsufficient = false}) {
    final Color cardColor = isInsufficient ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9);
    final Color accentColor = isInsufficient ? const Color(0xFFD32F2F) : const Color(0xFF00C853);
    final String label = isInsufficient ? "AMOUNT DUE" : "CHANGE RETURN";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: accentColor,
                radius: 20,
                child: Icon(
                  isInsufficient ? Icons.warning_amber_rounded : Icons.change_circle,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "LKR ${AppNumberFormat.formatNumber(num.parse(text).abs())}",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Opacity(
            opacity: 0.3,
            child: CircleAvatar(
              backgroundColor: accentColor,
              radius: 16,
              child: Text(
                isInsufficient ? "!" : "\$",
                style: const TextStyle(
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
