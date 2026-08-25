import 'package:bvibe/const/theme/theme.dart';
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Text(
                "LKR",
                style: TextStyle(
                  fontSize: 28,
                  color: AppColors.textHint,
                  fontWeight: FontWeight.w800,
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
                    fontSize: 28,
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
    final Color cardColor = isInsufficient
        ? const Color(0xFFFEF2F2)
        : const Color(0xFFF0FDF4);
    final Color accentColor = isInsufficient
        ? const Color(0xFFDC2626)
        : const Color(0xFF16A34A);
    final String label = isInsufficient ? "AMOUNT DUE" : "CHANGE RETURN";

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withOpacity(0.15),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isInsufficient
                      ? Icons.warning_amber_rounded
                      : Icons.change_circle,
                  color: accentColor,
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
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            ],
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
          padding: const EdgeInsets.symmetric(vertical: 22),
          backgroundColor: isConform
              ? AppColors.textSecondary
              : AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: isConform ? 0 : 4,
          shadowColor: isConform ? null : AppColors.primary.withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 22, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              "Confirm Payment",
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
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
              : AppColors.surface,
          padding: const EdgeInsets.symmetric(vertical: 18),
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
              size: 22,
              color: isConform ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Text(
              "Print Receipt",
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: isConform
                    ? Colors.white
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
