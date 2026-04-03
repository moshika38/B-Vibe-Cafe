import 'package:bvibe/features/history/widgets/details.table.dart';
import 'package:bvibe/features/history/widgets/items.cards.dart';
import 'package:bvibe/features/history/widgets/title.bar.dart';
import 'package:bvibe/features/orders/widgets/empty.item.dart';
import 'package:bvibe/invoice/invoice.page.dart';
import 'package:bvibe/provider/bill.history.provider.dart';
import 'package:bvibe/const/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  String? _selectedReceiptId;
  final FocusNode _focusNode = FocusNode();

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BillHistoryProvider>().fetchAllReceipts().then((_) {
          // Select the first receipt by default
          final provider = context.read<BillHistoryProvider>();
          if (provider.receipts.isNotEmpty && _selectedReceiptId == null) {
            setState(() {
              _selectedReceiptId = provider.receipts.first.receiptId;
            });
          }
          // Ensure keyboard navigation starts with focus
          _focusNode.requestFocus();
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      final provider = context.read<BillHistoryProvider>();
      final receipts = provider.receipts;
      if (receipts.isEmpty) return;

      final currentIndex = receipts.indexWhere(
        (r) => r.receiptId == _selectedReceiptId,
      );

      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        if (currentIndex < receipts.length - 1) {
          setState(() {
            _selectedReceiptId = receipts[currentIndex + 1].receiptId;
          });
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        if (currentIndex > 0) {
          setState(() {
            _selectedReceiptId = receipts[currentIndex - 1].receiptId;
          });
        }
      }
    }
  }

  void _fetchReceiptsByFilter(int id) {
    final provider = context.read<BillHistoryProvider>();
    final now = DateTime.now();

    switch (id) {
      case 0:
        provider.fetchAllReceipts();
        break;
      case 1:
        provider.fetchReceiptsByDateRange(now, now);
        break;
      case 2:
        provider.fetchReceiptsByDateRange(
          now.subtract(const Duration(days: 1)),
          now.subtract(const Duration(days: 1)),
        );
        break;
      case 3:
        provider.fetchReceiptsByDateRange(
          now.subtract(const Duration(days: 7)),
          now,
        );
        break;
      case 4:
        provider.fetchReceiptsByDateRange(
          now.subtract(const Duration(days: 30)),
          now,
        );
        break;
      case 5:
        provider.fetchArchivedReceipts();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKey,
      autofocus: true,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ItemsCards.header(context),
                IconButton(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedIndex = -1;
                        _selectedReceiptId = null;
                      });
                      if (context.mounted) {
                        context
                            .read<BillHistoryProvider>()
                            .fetchReceiptsByDateRange(picked, picked);
                      }
                    }
                  },
                  icon: const Icon(
                    Icons.calendar_month,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            TitleBar(
              onTap: (id) {
                setState(() {
                  selectedIndex = id;
                  _selectedReceiptId = null;
                });
                _fetchReceiptsByFilter(id);
              },
              onSearch: (query) {
                setState(() {
                  selectedIndex = -1;
                  _selectedReceiptId = null;
                });
                context.read<BillHistoryProvider>().searchReceipts(query);
              },
              selectedIndex: selectedIndex,
              tab: [
                "All Orders",
                "Today",
                "Yesterday",
                "Last 7 Days",
                "Last Month",
                "Archived Orders",
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Consumer<BillHistoryProvider>(
                builder: (context, billHistoryProvider, child) {
                  if (billHistoryProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (billHistoryProvider.receipts.isEmpty) {
                    return const Center(child: EmptyItem());
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          child: DetailsTable(
                            receipt: billHistoryProvider.receipts,
                            selectedId: _selectedReceiptId,
                            onSelect: (id) {
                              setState(() => _selectedReceiptId = id);
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          child: SingleChildScrollView(
                            child: InvoicePage.fromId(_selectedReceiptId ?? ""),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
