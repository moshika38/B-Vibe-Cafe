import 'package:flutter/material.dart';

class EmptyItem extends StatelessWidget {
  const EmptyItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/img/empty.png", width: 50),
          SizedBox(height: 10),
          Text("No Items ", style: Theme.of(context).textTheme.labelSmall),
          SizedBox(height: 5),
          Text(
            "This is empty section",
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
