import 'package:bvibe/components/app.buttons.dart';
import 'package:bvibe/const/theme/theme.dart';
import 'package:flutter/material.dart';

class AppBarTitle extends StatelessWidget {
  final String title;
  final String? addButtonText;
  final bool? isAddBtn;
  final VoidCallback? addBtnTap;
  const AppBarTitle({
    super.key,
    required this.title,
    this.addButtonText,
    this.isAddBtn,
    this.addBtnTap,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      height: 60,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium!.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),

            Row(
              children: [
                isAddBtn == true
                    ? AppButtons(
                        text: addButtonText ?? "Add New Item",
                        onTap: addBtnTap ?? () {},
                      )
                    : const SizedBox.shrink(),

                const SizedBox(width: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
