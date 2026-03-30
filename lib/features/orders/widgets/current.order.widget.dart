import 'package:flutter/material.dart';

class CurrentOrderWidget {
  static Widget tableHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text("Items", style: Theme.of(context).textTheme.labelSmall),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "Price",
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "Qty",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "Discount",
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "Total",
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}
