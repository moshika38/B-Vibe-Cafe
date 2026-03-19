import 'package:bvibe/const/theme.dart';
import 'package:flutter/material.dart';

class TableComponents {
  static Widget tableHead(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: Text("Invoice", style: theme.textTheme.labelSmall),
          ),
          Expanded(
            flex: 1,
            child: Text("Date", style: theme.textTheme.labelSmall),
          ),
          Expanded(
            flex: 1,
            child: Text("Time", style: theme.textTheme.labelSmall),
          ),
          Expanded(
            flex: 1,
            child: Text("Qty", style: theme.textTheme.labelSmall),
          ),
          Expanded(
            flex: 1,
            child: Text("Payment", style: theme.textTheme.labelSmall),
          ),
          Expanded(
            flex: 1,
            child: Text("Status", style: theme.textTheme.labelSmall),
          ),
        ],
      ),
    );
  }

  static Widget rowItem(
    int index,
    ThemeData theme,
    String text1,
    String text2,
    String text3,
    String text4,
    String text5,
    String text6,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: index % 2 == 1 ? AppColors.background : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(text1, style: theme.textTheme.labelSmall),
            ),
            Expanded(
              flex: 1,
              child: Text(text2, style: theme.textTheme.labelSmall),
            ),
            Expanded(
              flex: 1,
              child: Text(text3, style: theme.textTheme.labelSmall),
            ),
            Expanded(
              flex: 1,
              child: Text(text4, style: theme.textTheme.labelSmall),
            ),
            Expanded(
              flex: 1,
              child: Text(text5, style: theme.textTheme.labelSmall),
            ),
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  Icon(
                    text6 == "Paid" ? Icons.paid : Icons.do_not_disturb_alt,
                    size: 15,
                    color: text6 == "Paid"
                        ? AppColors.online
                        : Colors.redAccent,
                  ),
                  SizedBox(width: 5),
                  Text(
                    text6,
                    style: theme.textTheme.labelSmall!.copyWith(
                      color: text6 == "Paid"
                          ? AppColors.online
                          : Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
