import 'package:bvibe/components/navigation.title.dart';
import 'package:bvibe/const/theme/theme.dart';
import 'package:bvibe/data/workspace/dummy.dart';
import 'package:bvibe/features/orders/widgets/build.cate.card.dart';
import 'package:bvibe/features/orders/widgets/build.item.card.dart';
import 'package:bvibe/features/orders/widgets/current.order.dart';
import 'package:bvibe/features/orders/widgets/empty.item.dart';
import 'package:bvibe/provider/categories.helper.dart';
import 'package:bvibe/provider/item.provider.dart';
import 'package:bvibe/provider/receipt.provider.dart';
import 'package:bvibe/components/conform.window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CreateOrders extends StatefulWidget {
  final String invoiceId;
  const CreateOrders({super.key, required this.invoiceId});

  @override
  State<CreateOrders> createState() => _CreateOrdersState();
}

class _CreateOrdersState extends State<CreateOrders> {
  int activeCate = 0;
  int selectedItem = 0;
  String receiptId = "";

  Future? _categoriesFuture;
  Future? _itemsFuture;
  int? _lastActiveCate;
  int _maxCategories = 0;
  int _maxItems = 0;

  final FocusNode _focusNode = FocusNode();
  int _currentCrossAxisCount = 4;

  void _create() {
    final id = DummyData.dummyReceipt;
    setState(() {
      receiptId = id.receiptId;
    });
    Provider.of<ReceiptProvider>(context, listen: false).saveReceipt(id);
  }

  bool _handleGlobalKey(KeyEvent event) {
    if (!mounted || ModalRoute.of(context)?.isCurrent != true) return false;

    if (event is KeyDownEvent) {
      final bool isCtrlPressed =
          HardwareKeyboard.instance.isControlPressed ||
          HardwareKeyboard.instance.isLogicalKeyPressed(
            LogicalKeyboardKey.controlLeft,
          ) ||
          HardwareKeyboard.instance.isLogicalKeyPressed(
            LogicalKeyboardKey.controlRight,
          );
      final bool isShiftPressed = HardwareKeyboard.instance.isShiftPressed;

      if (event.logicalKey == LogicalKeyboardKey.delete) {
        showPinDialog(context).then((confirmed) {
          if (confirmed && mounted) {
            Provider.of<ReceiptProvider>(
              context,
              listen: false,
            ).deleteReceipt(receiptId);
            context.pop();
          }
        });
        return true;
      }

      if (isCtrlPressed &&
          (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
        context.push('/orders/checkout', extra: receiptId);
        return true;
      }

      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        if (isShiftPressed) {
          Provider.of<ReceiptProvider>(
            context,
            listen: false,
          ).updateOrderType(receiptId, 'Takeaway');
        } else if (isCtrlPressed) {
          final max = _maxCategories > 0 ? _maxCategories - 1 : 0;
          setState(() => activeCate = (activeCate + 1).clamp(0, max));
        } else {
          final max = _maxItems > 0 ? _maxItems - 1 : 0;
          setState(() => selectedItem = (selectedItem + 1).clamp(0, max));
        }
        return true;
      }

      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        if (isShiftPressed) {
          Provider.of<ReceiptProvider>(
            context,
            listen: false,
          ).updateOrderType(receiptId, 'Dine-In');
        } else if (isCtrlPressed) {
          final max = _maxCategories > 0 ? _maxCategories - 1 : 0;
          setState(() => activeCate = (activeCate - 1).clamp(0, max));
        } else {
          final max = _maxItems > 0 ? _maxItems - 1 : 0;
          setState(() => selectedItem = (selectedItem - 1).clamp(0, max));
        }
        return true;
      }

      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        final max = _maxItems > 0 ? _maxItems - 1 : 0;
        setState(() => selectedItem =
            (selectedItem + _currentCrossAxisCount).clamp(0, max));
        return true;
      }

      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() => selectedItem =
            (selectedItem - _currentCrossAxisCount).clamp(0, selectedItem));
        return true;
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    widget.invoiceId.isEmpty ? _create() : receiptId = widget.invoiceId;
    HardwareKeyboard.instance.addHandler(_handleGlobalKey);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNode.requestFocus(),
    );
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleGlobalKey);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    /// responsive breakpoints
    final bool isTablet = width < 1100;
    final bool isMobile = width < 750;

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        return KeyEventResult.ignored;
      },
      child: Container(
        color: AppColors.background,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: isMobile
              ? Column(
                  children: [
                    Expanded(child: _menuSection()),
                    const SizedBox(height: 20),
                    SizedBox(height: 350, child: _cartSection()),
                  ],
                )
              : Row(
                  children: [
                    Expanded(flex: isTablet ? 6 : 7, child: _menuSection()),
                    const SizedBox(width: 20),
                    Expanded(flex: 5, child: _cartSection()),
                  ],
                ),
        ),
      ),
    );
  }

  /// LEFT SIDE (Menu)
  Widget _menuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const NavigationTitle(
          title: "Orders",
          subtitle: "Create Orders",
          isBackIcon: true,
        ),

        TextField(
          decoration: InputDecoration(
            hintText: 'Search...',
            prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.textHint),
            ),
          ),
        ),

        const SizedBox(height: 20),

        Expanded(
          child: Consumer<CategoriesProvider>(
            builder: (context, provider, child) {
              _categoriesFuture ??= provider.readAllCategories();
              return FutureBuilder(
                future: _categoriesFuture,
                builder: (context, asyncSnapshot) {
                  if (asyncSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (asyncSnapshot.hasData) {
                    final categories = asyncSnapshot.data!;
                    _maxCategories = categories.length;

                    if (categories.isEmpty) {
                      return const Center(child: EmptyItem());
                    }

                    if (activeCate >= categories.length) {
                      Future.microtask(() {
                        if (mounted) setState(() => activeCate = 0);
                      });
                      return const Center(child: CircularProgressIndicator());
                    }

                    return Column(
                      children: [
                        SizedBox(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              return BuildCateCard(
                                isActive: index == activeCate,
                                title: categories[index].itemName,
                                icon: categories[index].iconNumber,
                                onTap: () {
                                  setState(() {
                                    activeCate = index;
                                    selectedItem = 0;
                                  });
                                },
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              int crossAxisCount = 4;

                              if (constraints.maxWidth < 800) {
                                crossAxisCount = 3;
                              }
                              if (constraints.maxWidth < 600) {
                                crossAxisCount = 2;
                              }

                              if (_currentCrossAxisCount != crossAxisCount) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (mounted) {
                                    setState(() =>
                                        _currentCrossAxisCount = crossAxisCount);
                                  }
                                });
                              }

                              return Consumer<ItemProvider>(
                                builder: (context, itemProv, child) {
                                  if (_lastActiveCate != activeCate) {
                                    _lastActiveCate = activeCate;
                                    _itemsFuture = itemProv.readAllItems(
                                      categories[activeCate].id ?? "",
                                    );
                                  }
                                  return FutureBuilder(
                                    future: _itemsFuture,
                                    builder: (context, itemSnapshot) {
                                      if (itemSnapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }

                                      if (itemSnapshot.hasData) {
                                        final data = itemSnapshot.data!;
                                        _maxItems = data.length;
                                        if (data.isEmpty) {
                                          return const EmptyItem();
                                        }
                                        return GridView.builder(
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: crossAxisCount,
                                                crossAxisSpacing: 10,
                                                mainAxisSpacing: 10,
                                                mainAxisExtent: 220,
                                              ),
                                          itemCount: data.length,
                                          itemBuilder: (context, index) {
                                            return BuildItemCard(
                                              isRetail: data[index].isRetail,
                                              itemId: data[index].id.toString(),
                                              cate: data[index].categoryId,
                                              cost: data[index].cost,
                                              des: data[index].description,
                                              receiptId: receiptId,
                                              image: data[index].imagePath,
                                              price: data[index].price
                                                  .toString(),
                                              title: data[index].itemName,
                                              isSelect: selectedItem == index,
                                              onTap: () {
                                                setState(() {
                                                  selectedItem = index;
                                                });
                                              },
                                            );
                                          },
                                        );
                                      }

                                      return const EmptyItem();
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }
                  return const Center(child: Text('Loading Categories...'));
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// RIGHT SIDE (Cart)
  Widget _cartSection() {
    return CurrentOrder(receiptId: receiptId);
  }
}
