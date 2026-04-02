import 'package:bvibe/const/theme/theme.dart';
import 'package:bvibe/data/model/receipt.model.dart';
import 'package:bvibe/data/workspace/datetime.format.dart';
import 'package:bvibe/features/history/widgets/table.components.dart';
import 'package:bvibe/data/workspace/number.format.dart';
import 'package:flutter/material.dart';

class DetailsTable extends StatefulWidget {
  final List<ReceiptModel> receipt;
  final String? selectedId;
  final Function(String id)? onSelect;

  const DetailsTable({
    super.key,
    required this.receipt,
    this.selectedId,
    this.onSelect,
  });

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
                  itemCount: widget.receipt.length,
                  itemBuilder: (context, index) {
                    final receipt = widget.receipt[index];
                    final isSelected = widget.selectedId == receipt.receiptId;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: InkWell(
                        onTap: () => widget.onSelect?.call(receipt.receiptId),
                        borderRadius: BorderRadius.circular(5),
                        child: Container(
                          decoration: isSelected
                              ? BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.04,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.primary,
                                    width: 1.5,
                                  ),
                                )
                              : null,
                          child: TableComponents.rowItem(
                            index,
                            theme,
                            receipt.receiptId,
                            DatetimeFormat.date(receipt.receiptCreateDate),
                            DatetimeFormat.time(receipt.receiptCreateTime),
                            receipt.items.length.toString(),
                            "${AppNumberFormat.formatNumber(double.tryParse(receipt.totalAmount) ?? 0.0)} LKR",
                            receipt.paymentStatus ? "Paid" : "Unpaid",
                          ),
                        ),
                      ),
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
