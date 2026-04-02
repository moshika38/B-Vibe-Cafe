import 'package:bvibe/components/app.buttons.dart';
import 'package:bvibe/const/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

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
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
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
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),

            Row(
              children: [
                isAddBtn == true
                    ? AppButtons(
                        text: addButtonText ?? "Add New Item",
                        onTap: addBtnTap ?? () {},
                      )
                    : SizedBox.fromSize(),

                SizedBox(width: 10),

                _iconButton(Symbols.notifications),
                SizedBox(width: 10),
                _iconButton(Symbols.help_sharp),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: AppColors.background,
      ),
      child: Icon(icon, size: 18, fill: 1, color: AppColors.textSecondary),
    );
  }
}
