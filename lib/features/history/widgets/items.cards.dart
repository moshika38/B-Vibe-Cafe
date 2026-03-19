
import 'package:flutter/material.dart';

class ItemsCards {
  static Widget header(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Order History",
          style: Theme.of(
            context,
          ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          "Manage and track all restaurant orders in real-time",
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }

 
}
