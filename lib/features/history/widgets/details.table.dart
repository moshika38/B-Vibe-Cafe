import 'package:bvibe/const/theme.dart';
import 'package:bvibe/features/history/widgets/table.components.dart';
import 'package:flutter/material.dart';

class DetailsTable extends StatefulWidget {
  const DetailsTable({super.key});

  @override
  State<DetailsTable> createState() => _DetailsTableState();
}

class _DetailsTableState extends State<DetailsTable> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.surface,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TableComponents.tableHead(theme),
              SizedBox(height: 10),
              Divider(),

              SizedBox(height: 10),

              Expanded(
                child: ListView.builder(
                  itemCount: 50,
                  itemBuilder: (context, index) {
                    return TableComponents.rowItem(
                      index,
                      theme,
                      "BVC00001",
                      "25/01/02",
                      "10:10 PM",
                      "2",
                      "10,700 LKR",
                       "Paid",
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
