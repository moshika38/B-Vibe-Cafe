import 'package:bvibe/components/navigation.title.dart';
import 'package:bvibe/const/theme/theme.dart';
import 'package:bvibe/data/model/receipt.model.dart';
import 'package:bvibe/features/orders/widgets/empty.item.dart';
import 'package:bvibe/features/orders/widgets/item.preview.dart';
import 'package:bvibe/features/orders/widgets/order.row.item.dart';
import 'package:bvibe/provider/receipt.provider.dart';
import 'package:bvibe/components/conform.window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class RecentOrders extends StatefulWidget {
  const RecentOrders({super.key});

  @override
  State<RecentOrders> createState() => _RecentOrdersState();
}

class _RecentOrdersState extends State<RecentOrders> {
  int selectIndex = 0;
  int _totalItems = 0;
  String selectInvoiceId = "";
  DateTime _selectedDate = DateTime.now();
  List<ReceiptModel> _currentReceipts = [];

  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  static const double _rowHeight = 58.0;

  void _createNewReceipt() {
    context.push("/orders/newOrder", extra: "");
  }

  void _updateSelection(int newIndex) {
    selectIndex = newIndex.clamp(0, (_totalItems - 1).clamp(0, _totalItems));
    if (_currentReceipts.isNotEmpty) {
      selectInvoiceId = _currentReceipts[selectIndex].receiptId;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNode.requestFocus(),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelected(int index) {
    if (!_scrollController.hasClients) return;

    final viewportHeight = _scrollController.position.viewportDimension;
    final currentScroll = _scrollController.offset;
    final itemTop = index * _rowHeight;
    final itemBottom = itemTop + _rowHeight;

    double? targetOffset;

    if (itemTop < currentScroll) {
      targetOffset = itemTop;
    } else if (itemBottom > currentScroll + viewportHeight) {
      targetOffset = itemBottom - viewportHeight;
    }

    if (targetOffset != null) {
      _scrollController.animateTo(
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent || event is KeyRepeatEvent) {
          final isCtrlPressed =
              HardwareKeyboard.instance.isControlPressed ||
              HardwareKeyboard.instance.isLogicalKeyPressed(
                LogicalKeyboardKey.controlLeft,
              ) ||
              HardwareKeyboard.instance.isLogicalKeyPressed(
                LogicalKeyboardKey.controlRight,
              );

          if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.keyN) {
            _createNewReceipt();
            return KeyEventResult.handled;
          }

          if (event.logicalKey == LogicalKeyboardKey.delete) {
            if (_currentReceipts.isNotEmpty) {
              showPinDialog(context).then((confirmed) {
                if (confirmed) {
                  Provider.of<ReceiptProvider>(context, listen: false)
                      .deleteReceipt(selectInvoiceId);
                  setState(() => selectIndex = 0); // Reset selection safely
                }
              });
            }
            return KeyEventResult.handled;
          }

          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            setState(() => _updateSelection(selectIndex + 1));
            _scrollToSelected(selectIndex);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            setState(() => _updateSelection(selectIndex - 1));
            _scrollToSelected(selectIndex);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            if (_currentReceipts.isEmpty) return KeyEventResult.ignored;

            final isPaid = _currentReceipts[selectIndex].paymentStatus;
            final invoiceId = _currentReceipts[selectIndex].receiptId;

            if (isCtrlPressed) {
              if (isPaid) {
                context.push('/orders/viewOrder', extra: invoiceId);
              } else {
                context.push('/orders/newOrder', extra: invoiceId);
              }
              return KeyEventResult.handled;
            } else {
              if (isPaid) {
                context.push('/orders/viewOrder', extra: invoiceId);
              } else {
                context.push('/orders/checkout', extra: invoiceId);
              }
              return KeyEventResult.handled;
            }
          }
        }
        return KeyEventResult.ignored;
      },
      child: Container(
        color: AppColors.background,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: NavigationTitle(
                      title: "Orders",
                      subtitle: "Recent orders",
                      isBtn: true,
                      onTap: () => _createNewReceipt(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null && picked != _selectedDate) {
                          setState(() {
                            _selectedDate = picked;
                            selectIndex = 0;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}",
                              style: theme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left sidebar
                    Container(
                      width: 200,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      margin: const EdgeInsets.only(right: 20),
                      child: ItemPreview(invoiceId: selectInvoiceId),
                    ),

                    // Main table
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Table header
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft.withValues(alpha: 0.3),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 250,
                                    child: Text(
                                      'Invoice Number',
                                      style: theme.labelSmall?.copyWith(
                                        color: AppColors.textHint,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 150,
                                    child: Text(
                                      'Items',
                                      style: theme.labelSmall?.copyWith(
                                        color: AppColors.textHint,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 150,
                                    child: Text(
                                      'Date',
                                      style: theme.labelSmall?.copyWith(
                                        color: AppColors.textHint,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 100,
                                    child: Text(
                                      'Time',
                                      style: theme.labelSmall?.copyWith(
                                        color: AppColors.textHint,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 100,
                                    child: Text(
                                      'Status',
                                      textAlign: TextAlign.center,
                                      style: theme.labelSmall?.copyWith(
                                        color: AppColors.textHint,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Amount',
                                      textAlign: TextAlign.end,
                                      style: theme.labelSmall?.copyWith(
                                        color: AppColors.textHint,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Table rows
                            Consumer<ReceiptProvider>(
                              builder: (context, value, child) => Expanded(
                                child: FutureBuilder(
                                  future: value.getReceiptsByDateRange(
                                    _selectedDate,
                                    _selectedDate,
                                  ),
                                  builder: (context, asyncSnapshot) {
                                    if (asyncSnapshot.hasData) {
                                      final receipt = asyncSnapshot.data!;

                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                            bool shouldUpdate = false;
                                            if (_totalItems != receipt.length) {
                                              shouldUpdate = true;
                                            } else {
                                              // Thoroughly check if any item's ID or payment status has changed
                                              for (int i = 0; i < receipt.length; i++) {
                                                if (_currentReceipts.isEmpty ||
                                                    i >= _currentReceipts.length ||
                                                    _currentReceipts[i].receiptId != receipt[i].receiptId ||
                                                    _currentReceipts[i].paymentStatus != receipt[i].paymentStatus) {
                                                  shouldUpdate = true;
                                                  break;
                                                }
                                              }
                                            }

                                            if (shouldUpdate && mounted) {
                                              setState(() {
                                                _totalItems = receipt.length;
                                                _currentReceipts = receipt;
                                                if (receipt.isNotEmpty &&
                                                    selectIndex >=
                                                        receipt.length) {
                                                  selectIndex = 0;
                                                }
                                                if (receipt.isNotEmpty) {
                                                  selectInvoiceId =
                                                      receipt[selectIndex]
                                                          .receiptId;
                                                }
                                              });
                                            }
                                          });

                                      if (receipt.isEmpty) {
                                        return EmptyItem();
                                      }

                                      return ListView.builder(
                                        controller: _scrollController,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 0,
                                        ),
                                        itemCount: receipt.length,
                                        itemBuilder: (context, index) {
                                          return OrderRowItem(
                                            index: index,
                                            isSelect: selectIndex == index,
                                            onTap: () => setState(() {
                                              _updateSelection(index);
                                              _focusNode.requestFocus();
                                            }),
                                            navigateTap: () {
                                              receipt[index].paymentStatus
                                                  ? context.push(
                                                      '/orders/viewOrder',
                                                      extra: receipt[index]
                                                          .receiptId,
                                                    )
                                                  : context.push(
                                                      '/orders/newOrder',
                                                      extra: receipt[index]
                                                          .receiptId,
                                                    );
                                            },
                                            invoiceNumber:
                                                receipt[index].receiptId,
                                            items: receipt[index].items.length
                                                .toString(),
                                            time: receipt[index]
                                                .receiptCreateDate,
                                            amount: receipt[index].totalAmount,
                                            status:
                                                receipt[index].paymentStatus,
                                          );
                                        },
                                      );
                                    }
                                    return EmptyItem();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
